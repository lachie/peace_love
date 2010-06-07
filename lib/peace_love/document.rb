
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
      def sub_document(field,mod)
        Doc.register_mixin(self,field,mod)
      end
      alias_method :sub_doc, :sub_document

      def sub_collection(field,mod)
      end
      alias_method :sub_col, :sub_collection
    end
  end
end
