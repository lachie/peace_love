module PeaceLove
  class Db
    attr_reader :db,:mixins

    def initialize(db,mixins)
      @db = db || raise("#{self} requires a non-nil db")
      @mixins = mixins
    end

    def collections
      @collections ||= {}
    end

    def [](collection_name)
      collections[collection_name] ||= PeaceLove::Collection.new( db[collection_name], mixins[collection_name] )
    end
  end
end
