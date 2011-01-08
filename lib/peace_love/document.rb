require 'angry_hash/extension'

module PeaceLove
  module Doc
    def self.included(base)
      base.send :include, AngryHash::Extension
      base.send :include, OidHelper
      base.extend ClassMethods
      base.extend OidHelper
    end


    def __collection=(col)
      @collection = col
    end

    def __parent_hash=(doc)
      self.__collection = doc.__collection if doc.respond_to?(:__collection)
      super
    end

    def __collection
      @collection
    end

    module ClassMethods
      def mongo(options)
        PeaceLove.mixin_config[options[:db]][options[:collection]] = self
      end
      def mongo_collection(collection_name)
        PeaceLove.mixin_config[nil][collection_name] = self
      end

      def collection
        @collection ||= PeaceLove.collection_for_mixin(self)
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
