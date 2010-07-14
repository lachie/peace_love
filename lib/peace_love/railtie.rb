require 'erb'
require 'yaml'

module Rails #:nodoc:
  module PeaceLove #:nodoc:
    class Railtie < Rails::Railtie #:nodoc:
      initializer 'setup db' do
        # use database.yml to setup mongo
        config_file = Rails.root + "config/database.yml"
        if config_file.file?
          settings = YAML.load( ERB.new(config_file.read).result )[Rails.env]
          ::PeaceLove.connect(settings)
        end
      end

      initializer "check connection" do
        unless ::PeaceLove.db.present?
          cfg_file = Rails.root.join('config/database.yml')
          cfg_file.exist? or raise(<<-EOMSG)
Unable to connect to mongodb: #{cfg_file} doesn't exist.
You need to set up a #{cfg_file} looking like\n
#{Rails.env}:
  database: yourdb
  host: localhost

          EOMSG
          raise( "Unable to connect to mongodb using #{Rails.root+'config/database.yml'}" )
        end
      end
    end
  end
end
