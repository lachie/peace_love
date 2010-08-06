module PeaceLove
  class Collection
    attr_reader :mongo_collection

    def initialize(collection)
      @collection = @mongo_collection = collection
    end

    def mixin=(mixin)
      mixin.collection = @mongo_collection.name
    end
    def set_mixin(mixin)
      @mixin = mixin
    end
    attr_reader :mixin

    def build(seed={})
      __wrap( seed )
    end

    def find_one(*args)
      __wrap( @collection.find_one(*args) )
    end

    def find(*args,&block)
      if block_given?
        @collection.find(*args) {|cursor| yield __wrap_cursor(cursor)}
      else
        __wrap_cursor(@collection.find(*args))
      end
    end

    # TODO find_and_modify

    def __wrap_cursor(cursor)
      PeaceLove::Cursor.new(cursor,self)
    end

    def __wrap(hash)
      return nil unless hash.respond_to?(:to_hash)

      hash = __extend( AngryHash[ hash ] )
      hash
    end

    def __extend(doc)
      if mixin
        doc.extend mixin 
        doc.__collection = self if doc.respond_to?(:__collection=)
      end

      doc
    end

    (Mongo::Collection.instance_methods - self.instance_methods).each do |name|
      next if name[-1] == ?=
      class_eval "def #{name}(*args,&block); @collection.#{name}(*args,&block) end" unless method_defined?(name)
    end
  end

end
