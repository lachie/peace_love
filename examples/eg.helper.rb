require 'rubygems'
require 'bundler'
Bundler.setup(:test,:default)
require 'exemplor'

require 'pp'

require 'pathname'

here = Pathname('..').expand_path(__FILE__)
$LOAD_PATH << here << (here+'../lib')

class Object
  def tapp(tag=nil)
    print "#{tag}=" if tag
    pp self
    self
  end
end

require 'mongo'

# In YAML, output BSON ObjectIds succinctly.
class BSON::ObjectID
  def to_yaml(opts = {})
    YAML.quick_emit(nil, opts) do |out|
      out.scalar(nil, "oid(#{to_s})", :plain)
    end
  end
end

$mongo = Mongo::Connection.new
$db    = $mongo.db('sample-db')
