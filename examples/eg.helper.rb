require 'rubygems'
require 'bundler'
Bundler.setup(:test,:default)
require 'exemplor'

require 'pp'

require 'pathname'
here = Pathname(__FILE__).dirname
$LOAD_PATH << here << (here+'../lib')

class Object
  def tapp(tag=nil)
    print "#{tag}=" if tag
    pp self
    self
  end
end

require 'mongo'
$db = Mongo::Connection.new.db('sample-db')
