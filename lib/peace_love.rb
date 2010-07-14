require 'mongo'
require 'angry_hash'

module PeaceLove
end

require 'peace_love/document'
require 'peace_love/collection'
require 'peace_love/cursor'

module PeaceLove
  class << self
    attr_accessor :db, :connection

    def collections
      @collections ||= {}
    end

    def [](collection_name)
      collections[collection_name.to_s] ||= PeaceLove::Collection.new( db[collection_name] )
    end

    def connect(options)
      options = AngryHash[options]

      if options.port?
        options.port = options.port.to_i
      end

      options.delete('adapter') # XXX check?

      # TODO - support paired servers
      self.connection = Mongo::Connection.new(options.delete('host'), options.delete('port'), options)
      self.db         = connection.db(options.database)
    end
  end
end
