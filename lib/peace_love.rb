require 'mongo'
require 'angry_hash'

module PeaceLove
end

require 'peace_love/document'
require 'peace_love/collection'
require 'peace_love/cursor'

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
end
