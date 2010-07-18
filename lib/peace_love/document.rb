
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
        @object_extensions ||= {}
      end

      def mark_extension(obj,with)
        if (previously_with = object_extensions[obj.__id__]) && previously_with != with
          raise "object #{obj} has already been extended by a different PeaceLove::Doc (was: #{previously_with}, now: #{with})"
        end
        object_extensions[obj.__id__] = with
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
        doc.extend mod
        doc.__parent_doc = parent_obj if doc.respond_to?(:__parent_doc=)
        doc
      end

      def mixin_to(parent_obj,field,obj)
        extension = object_extensions[parent_obj.__id__]

        if mixin = mixin_registry[extension][field.to_s]
          kind,mod,options = *mixin

          if options.key?(:default) && obj.nil?
            obj = options[:default]
          end

          # XXX - what happens when obj is nil

          case kind
          when :single
            extend_doc(obj,mod,parent_obj)
          when :array
            # XXX - this is ok for now... we really need to typecheck, perhaps wrap in a smart-array


            obj.map! {|elt| extend_doc elt, mod, parent_obj}
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
      def collection=(collection_name)
        @collection = PeaceLove[collection_name]
        @collection.set_mixin(self)
      end
      alias mongo_collection collection=

      def collection
        @collection
      end
      
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
