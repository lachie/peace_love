
module PeaceLove
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

      def register_mixin(target_class,field,mod,options)
        mixin_registry[target_class][field.to_s] = [:single, mod, options]
      end
      def register_mixin_array(target_class, field, mod, options)
        mixin_registry[target_class][field.to_s] = [:array, mod, options]
      end

      def extend_doc(doc,mod,parent_obj)
        obj.extend mod
        obj.__parent_doc = parent_obj if obj.respond_to?(:__parent_doc=)
      end

      def mixin_to(parent_obj,field,obj)
        # XXX - what does having multiple extensions really mean here?
        extensions = object_extensions[parent_obj.__id__]

        mixins = mixin_registry.values_at(*extensions).map {|m| m[field.to_s]}.compact

        mixins.each {|(kind,mod,options)|
          if options.key?(:default) && obj.nil?
            obj = options[:default]
          end

          # XXX - what happens when obj is nil

          case kind
            when :single
              extend_doc(doc,mod,parent_obj)
            when :array
              # XXX - this is ok for now... we really need to typecheck, perhaps wrap in a smart-array
              obj.map! {|elt| extend_doc elt, mod, parent_obj}
            end
        }

        obj
      end
    end

    def [](key)
      Doc.mixin_to(self,key,super)
    end

    def __source_collection=(col)
      @source_collection = col
    end
    def __parent_doc(doc)
      self.__source_collection = doc.__source_collection if doc.respond_to?(:__source_collection)
      @parent_doc = doc
    end

    def __parent_doc
      @parent_doc
    end

    def __source_collection
      @source_collection
    end

    module ClassMethods
      def sub_document(field,mod,options={})
        Doc.register_mixin(self,field,mod,options)
      end
      alias_method :sub_doc, :sub_document

      def sub_collection(field,mod,options={})
        Doc.register_mixin_array(self,field,mod,options)
      end
      alias_method :sub_col, :sub_collection

      def build(seed={})
        doc = AngryHash[ seed ]
        doc.extend self
        doc
      end
    end
  end
end
