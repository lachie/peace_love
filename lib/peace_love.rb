require 'mongo'
require 'angry_hash'

module PeaceLove
  autoload :Db, 'peace_love/db'
  autoload :Doc, 'peace_love/document'
  autoload :Collection, 'peace_love/collection'
  autoload :Cursor, 'peace_love/cursor'
  autoload :OidHelper, 'peace_love/oid_helper'

  class << self
    attr_accessor :default_db, :mongo, :connection

    def dbs
      @dbs ||= {}
    end

    def [](*db_name)
      if db_name = db_name.flatten.compact.pop
        dbs[db_name.to_s] ||= PeaceLove::Db.new( mongo[db_name], mixin_config[db_name] )
      else
        @wrapped_default_db ||= PeaceLove::Db.new( default_db, mixin_config[nil] )
      end
    end

    def mixin_config
      @mixin_config ||= Hash.new {|h,k| h[k] = {}}
    end

    def collection_for_mixin(mixin)
      mixin_config.each do |db,db_mixins|
        db_mixins.each do |col,col_mixin|
          if col_mixin == mixin
            return self[db][col]
          end
        end
      end
    end

    def connect(options)
      options = AngryHash[options]

      if options.port?
        options.port = options.port.to_i
      end

      options.delete('adapter') # XXX check?

      self.connection = Mongo::Connection.new(options.delete('host'), options.delete('port'), options)
      self.default_db = connection.db(options.database)
    end
  end
end
