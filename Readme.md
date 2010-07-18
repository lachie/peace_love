# PeaceLove & Mongo

PeaceLove is a simple mixin layer for enhancing hashes retrieved from MongoDB. PeaceLove eschews the mapping compulsion of ruby Mongo libraries.

## Install

    gem install peace_love

## Basic Usage

    require 'rubygems'

    require 'bson_ext'
    require 'mongo'

    require 'peace_love'

(Right now you have to set up your database before defining any mixins. This limitation will be fixed soon.)

    mongo = Mongo::Connection.new
    PeaceLove.db = mongo['bean_db']

Now define some mixins

    module Bean
      include PeaceLove::Doc
      mongo_collection 'beans'

      def is_a_bean?; true end
    end

Now lets insert something:

    lima_bean  = { :name => 'lima' }
    human_bean = { :name => 'Arthur', :prefered_drinks => %w[tea] }

    PeaceLove['beans'].insert(lima_bean)
    PeaceLove['beans'].insert(human_bean)

`PeaceLove['beans']` returns a `PeaceLove::Collection` which thinly wraps a `Mongo::Collection`. See how to use it in the [Mongo Ruby API][monapi]

Notice how we're inserting hashes. PeaceLove only mixes in hashes coming _out_ of Mongo.

Also note that the wrapping of `Mongo::Collection` may not yet be complete.

### Fetching single documents

Let's fetch Arthur:

    arthur = PeaceLove['beans'].find_one(:name => 'Arthur')

Now what can we do with him?

    arthur.is_a_bean?        #=> true

`#is_a_bean?` was defined on the module `Bean`. Nice.

Now fetch some plain values:

    arthur[:prefered_drinks] #=> [ 'tea' ]
    arthur.prefered_drinks   #=> [ 'tea' ]

    arthur.is_a?(Hash)       #=> true
    arthur.class             #=> AngryHash

Among other things, [`AngryHash`][ah] adds dot-notation accessors to hashes.

### Updating

Arthur discovered a new drink. Let's update:

    PeaceLove['beans'].update({:_id => arthur._id}, '$push' => {'prefered_drinks' => 'pan-galactic gargle blaster'})

    arthur = PeaceLove['beans'].find_one(:name => 'Arthur')

    arthur.prefered_drinks #=> [ 'tea', 'pan-galactic gargle blaster' ]

Here we're using normal Mongo powers to do an atomic push onto `arthur.prefered_drinks`

### Fetching a list

    PeaceLove['beans'].find(:name => 'lima').each {|bean| # ... work}

`#find` returns a `PeaceLove::Cursor` which thinly wraps a `Mongo::Cursor`. It mixes in `Enumerable`.

### Building

To build a hash imbued with module powers, without touching mongo, use `#build`:

    arthur = PeaceLove['beans'].build(:name => 'arthur')
    
## Sub structure

### Sub documents

Sub documents allow you to mix modules into parts of the document.

    module Taste
      def zesty?
        spicy? && sour?
      end
    end

    module Bean
      include PeaceLove::Doc
      mongo_collection 'beans'
      
      sub_doc :taste, Taste
    end

    chaos = PeaceLove['beans'].build(:name => 'chaos', :taste => {:sour => true, :spicy => true})
    chaos.taste.zesty? #=> true

### Sub collections

Sub collections allow you to mix modules into each element of arrays (and in the future hashes) contained in the document.

    module Colour
      def happy?
        name == 'red' || name == 'yellow'
      end
    end

    module Bean
      include PeaceLove::Doc
      mongo_collection 'beans'
      
      sub_col :taste, Taste
    end

    bean = PeaceLove['beans'].build(:name => 'jelly-belly', :colours => [
                                                                          {:name => 'red'},
                                                                          {:name => 'green'},
                                                                          {:name => 'magenta'}
                                                                        ])

    bean.colours[0].name   #=> 'red'
    bean.colours[0].happy? #=> true
    bean.colours[1].name   #=> 'green'
    bean.colours[1].happy? #=> false

### Railtie

There's a simple rails 3 `railtie` for setting up the MongoDB connection using details in `database.yml`.

It will probably become more sophisticated over time.

## Rationale

or: why not map Mongo?

### Mongo's ruby driver is unusually good

Unusually good for database drivers, that is. By contrast SQL drivers (& underlying SQL engines) tend to be a bit shaggy due 
to the profusion of databases and sellers thereof.
Thus, part of the attraction of an ORM is papering over all the SQL driver shagginess.

There's only one MongoDB implementation so far, and only one vendor, 10gen.

10gen has created a good, rubyish driver for it (though apparently it can be a mite laggy, versionwise)

Therefore, lets enjoy what we have.

### Mongo's data approach is good.

BSON is binary JSON, and Mongo's interface is (mostly) based on it (the notable exception being MapReduce, for which you use Javascript).

Day-to-day querying and commanding of the database is done through BSON, which means that its logic free & injection safe.

You can do so much with the BSON interface, simply and neatly; I don't quite see the point in abstracting it away behind an expensive ruby interface.

### DIY or don't.

If you want to abstract or DRY stuff away, do it yourself, in a `PeaceLove::Doc` module. 

Or, use one of the mappers :)

## Limitations

Documents are hashes. This means that if your hash keys collide with method names, you'll either have to access them using normal `[:key]` syntax
or you can override the method:

    def key; self['key'] end # Hash#key is defined in ruby 1.9.

The only exception is `Object#id`. In late ruby 1.8's its deprecated but still exists. In ruby 1.9 its been removed. I therefore decided to override it
in `PeaceLove::Doc` since I wanted to use `#id` to store my own non-mongo ids.

## TODO

* The core mixin mechanics of PeaceLove aren't actually bound to MongoDB at all. I'd like to split out the mongo-specific & -non-specific parts.
* Sub collections can only be arrays. They should be able to be hashes too.

## About

Please report problems at http://github.com/lachie/peace_love/issues.

PeaceLove is by Lachie Cox.

The code is hosted on GitHub and can be found at http://github.com/lachie/peace_love.

You're free to use PeaceLove under the MIT license, see License for details.

[ah]: http://github.com/plus2/angry_hash
[monapi]: http://api.mongodb.org/ruby/1.0.5/Mongo/Collection.html

