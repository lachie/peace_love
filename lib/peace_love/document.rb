
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

      def register_mixin(target_class,field,mod)
        mixin_registry[target_class][field.to_s] = [:single, mod]
      end
      def register_mixin_array(target_class, field, mod)
        mixin_registry[target_class][field.to_s] = [:array, mod]
      end

      def mixin_to(parent_obj,field,obj)
        extensions = object_extensions[parent_obj.__id__]

        mixins = mixin_registry.values_at(*extensions).map {|m| m[field.to_s]}.compact
        
        mixins.each {|(kind,mod)|
          case kind
            when :single
              obj.extend mod
            when :array
              # XXX - this is ok for now... we really need to typecheck, perhaps wrap in a smart-array
              obj.map! {|elt| elt.extend mod}
            end
        }

        obj
      end
    end

    def [](key)
      Doc.mixin_to(self,key,super)
    end

    module ClassMethods
      def sub_document(field,mod)
        Doc.register_mixin(self,field,mod)
      end
      alias_method :sub_doc, :sub_document

      def sub_collection(field,mod)
        Doc.register_mixin_array(self,field,mod)
      end
      alias_method :sub_col, :sub_collection
    end
  end
end
