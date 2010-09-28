require 'angry_hash/extension'

module PeaceLove
  module Doc
    def self.included(base)
      base.send :include, AngryHash::Extension
      base.extend ClassMethods
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

    module ClassMethods
      def collection=(collection_name)
        @collection = PeaceLove[collection_name]
        @collection.set_mixin(self)
      end
      alias mongo_collection collection=

      def collection
        @collection
      end

      include AngryHash::Extension::ClassMethods

      alias_method :sub_document, :extend_value
      alias_method :sub_doc, :extend_value

      alias_method :sub_document, :extend_array
      alias_method :sub_col, :extend_array

      alias_method :sub_hash, :extend_hash
    end
  end
end
