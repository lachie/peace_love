
module PeaceLove
  module Doc
    class << self
      def included(base)
        base.extend ClassMethods

        base.module_eval do
          def self.extend_object(obj)
            super
            Doc.mark_extension(obj,self)
          end
        end
      end

      def mark_extension(doc,mod)
        #puts "mark_extension doc=#{doc.class} mod=#{mod}"
        
        # TODO store extension on the doc!
        if (previous_mod = doc.__peace_love_extension) && previous_mod != mod
          raise "doc #{doc} has already been extended by a different PeaceLove::Doc (was: #{previous_mod}, now: #{mod})"
        end
        doc.__peace_love_extension = mod

        setup_extended_doc(doc,mod)
      end

      def mixin_registry
        @mixin_registry ||= Hash.new {|h,k| h[k] = {}}
      end

      def register_mixin(target_class,field,mod,options)
        mixin_registry[target_class][field.to_s] = [:single, mod, options]
      end

      def register_mixin_array(target_class, field, mod, options)
        mixin_registry[target_class][field.to_s] = [:array, mod, options]
      end

      def register_mixin_hash(target_class, field, mod, options)
        mixin_registry[target_class][field.to_s] = [:hash, mod, options]
      end

      def extend_doc(doc,mod,parent_doc)
        # puts "extend_doc doc=#{doc.class} mod=#{mod} parent_obj=#{parent_obj.class}"

        if !parent_doc.nil? && doc.nil?
          doc = AngryHash.new
        end

        doc.extend mod

        doc.__parent_doc = parent_doc if doc.respond_to?(:__parent_doc=)
        doc
      end

      def setup_extended_doc(doc,mod)
        mod.fill_in_defaults(doc) if mod.respond_to?(:fill_in_defaults)
        doc
      end

      def mixin_to(parent_obj,field,obj)
        # puts "mixin_to field=#{field}"

        extension = parent_obj.__peace_love_extension
        # puts "found extension=#{extension.inspect}"

        if mixin = mixin_registry[extension][field.to_s]
          kind,mod,options = *mixin

          if options.key?(:default) && obj.nil?
            obj = options[:default]
          end

          case kind
          when :single
            obj = extend_doc(obj,mod,parent_obj)
          when :array
            # XXX - this is ok for now... we really need to typecheck, perhaps wrap in a smart-array
            obj ||= []
            obj = obj.map {|elt| extend_doc(elt, mod, parent_obj)}
          when :hash
            obj ||= {}
            obj = obj.inject(AngryHash.new) do |h,(k,elt)|
              h[k] = extend_doc(elt,mod,parent_obj)
              h
            end
          end
        end

        obj
      end
    end

    def [](key)
      Doc.mixin_to(self,key,super)
    end

    def id
      self['id']
    end

    def __collection=(col)
      @collection = col
    end

    def __parent_doc=(doc)
      self.__collection = doc.__collection if doc.respond_to?(:__collection)
      @parent_doc = doc
    end

    def __parent_doc
      @parent_doc
    end

    def __collection
      @collection
    end

    def __peace_love_extension=(mod)
      @__peace_love_extension = mod
    end

    def __peace_love_extension
      @__peace_love_extension
    end

    module ClassMethods
      def collection=(collection_name)
        @collection = PeaceLove[collection_name]
        @collection.set_mixin(self)
      end
      alias mongo_collection collection=

      def collection
        @collection
      end

      def defaults(default_form=nil)
        if default_form
          @default_form = default_form
        end
        @default_form
      end

      def fill_in_defaults(doc)
        if defaults
          doc.reverse_deep_update(defaults)
        end
      end
      
      def sub_document(field,mod,options={})
        Doc.register_mixin(self,field,mod,options)
      end
      alias_method :sub_doc, :sub_document

      def sub_collection(field,mod,options={})
        Doc.register_mixin_array(self,field,mod,options)
      end
      alias_method :sub_col, :sub_collection

      def sub_hash(field,mod,options={})
        Doc.register_mixin_hash(self,field,mod,options)
      end

      def build(seed={})
        doc = AngryHash[ seed ]
        self.fill_in_defaults(doc)
        doc.extend self
        doc
      end
    end
  end
end
