require 'eg.helper'
require 'angry_hash'


module PeaceLove
  class << self
    attr_accessor :db

    def collections
      @collections ||= {}
    end

    def [](collection_name)
      collections[collection_name.to_s] ||= PeaceLove::Collection.new( db[collection_name] )
    end
  end

  class Collection


    attr_accessor :mixin

    def initialize(collection)
      @collection = collection
    end

    def build(seed={})
      __extend( AngryHash[ seed ] )
    end

    def find_one(*args)
      __extend( AngryHash[ @collection.find_one(*args) ] )
    end

    def find(*args,&block)
      if block_given?
        find(*args) {|cursor| yield __extend_cursor(cursor)}
      else
        __extend_cursor(find(*args))
      end
    end

    def __extend_cursor(cursor)
    end

    def __extend(hash)
      hash.extend mixin if mixin
      hash
    end

    (Mongo::Collection.instance_methods - self.instance_methods).each do |name|
      next if name[-1] == ?=
      class_eval "def #{name}(*args,&block); @collection.#{name}(*args,&block) end"
    end
  end

  module Doc
    class << self
      def included(base)
        base.extend ClassMethods

        base.module_eval do
          def self.extend_object(obj)
            Doc.mark_extension(obj,self)
            super
          end
        end
      end

      def object_extensions
        @object_extensions ||= Hash.new {|h,k| h[k] = []}
      end
      def mark_extension(obj,with)
        object_extensions[obj.__id__] << with
      end

      def mixin_registry
        @mixin_registry ||= Hash.new {|h,k| h[k] = {}}
      end
      def register_mixin(target_class,field,mod)
        mixin_registry[target_class][field.to_s] = mod
      end

      def mixin_to(parent_obj,field,obj)
        extensions = object_extensions[parent_obj.__id__]

        mixins = mixin_registry.values_at(*extensions)

        mixins.map {|m| m[field.to_s]}.flatten.compact.each {|mod| obj.extend mod}
        obj
      end
    end

    def [](key)
      Doc.mixin_to(self,key,super)
    end

    module ClassMethods
      def sub_doc(field,mod)
        Doc.register_mixin(self,field,mod)
      end

      def sub_collection(field,mod)
      end
    end
  end
end

eg.setup do
  PeaceLove.db = $db
end


module Kind
  def claws; "dainty" end

  def for_kids?
    fictional? && cartoon?
  end
end

module Bear
  include PeaceLove::Doc
  sub_doc :kind, Kind

  def claws; "woah" end
  def liver
    super.upcase
  end
end

eg 'loading object' do
  $db['bears'].remove()
  $db['bears'].insert(:name => 'yogi', :liver => 'pure', :kind => {:fictional => true, :cartoon => true})

  PeaceLove['bears'].mixin = Bear
  yogi = PeaceLove['bears'].find_one(:name => 'yogi')
  Show(yogi.claws)
  Show(yogi.name)
  Show(yogi.liver)
  Show(yogi.kind.for_kids?)
end

eg 'blank doc' do
  PeaceLove['bears'].mixin = Bear
  yogi = PeaceLove['bears'].build
  yogi.claws
end

eg 'saving object' do
  h = AngryHash[ :somesuch => 'second thing' ]
  id = PeaceLove['bears'].insert( h )
  PeaceLove['bears'].find_one(id)
end
