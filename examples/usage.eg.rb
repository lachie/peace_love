require 'eg.helper'
require 'angry_hash'
require 'peace_love'



## Fixtures
# Here are a couple of modules we're going to mix into hashes from Mongo.

# Note that `PeaceLove.db` needs to be set before `mongo_collection` is called.
# This will be fixed in the future.
PeaceLove.db = $db

module Kind
  def healthy; "healthy" end

  def kids_love?
    fictional?
  end
end

module Bean
  include PeaceLove::Doc
  sub_doc :kind  , Kind
  sub_col :examples, Bean

  mongo_collection 'beans'

  def texture; super.upcase end
end

eg.setup do

  @mongo_beans = $db['beans']
  @mongo_beans.remove()

  @peace_love_beans = PeaceLove['beans']
end

eg.helpers do
  attr_reader :mongo_beans, :peace_love_beans
end


eg 'loading a document' do
  mongo_beans.insert(:name    => 'lima',
                     :texture => 'crunchy',
                     :colours => %w[green white],
                     :kind => {:grown     => true,
                               :fictional => false
                              }
                    )

  lima = peace_love_beans.find_one(:name => 'lima')

  # attributes on the document
  Assert( lima.name         == 'lima'          )
  Assert( lima.colours      == %w[green white] )

  # methods on a document
  Assert( lima.texture      == 'CRUNCHY' )

  # sub-document
  Assert( lima.kind.grown? )

  # methods on a sub-doc
  Assert(   lima.kind.healthy == 'healthy' )
  Assert( ! lima.kind.kids_love? )

end


eg 'loading a non-existent documents' do
  b = peace_love_beans.find_one(:name => 'delicious')

  Assert( b.nil? )
end



eg 'loading a list of documents' do
  mongo_beans.insert(:name => 'baked'  , :texture => 'Mushy'  , :kind => {:fictional => false })
  mongo_beans.insert(:name => 'magical', :texture => 'sparkly', :kind => {:fictional => true  })

  i = 0
  peace_love_beans.find.each {|b|

    case i
    when 0
      Assert( b.name == 'baked'    )
      Assert( ! b.kind.kids_love?  )
      Assert( b.texture == 'MUSHY' )
    when 1
      Assert( b.name == 'magical'    )
      Assert( b.kind.kids_love?      )
      Assert( b.texture == 'SPARKLY' )
    end

    i += 1
  }
end

eg 'loading a hash of documents' do
  mongo_beans.insert(:name => 'baked', :examples_hash => { 'yummy' => {:named => 'yummy', :texture => 'sandy'}, 'yucky' => {:named => 'yiccko'} } )

  baked = peace_love_beans.find_one(:name => 'baked')

  Assert( baked.examples_hash.yummy.named == 'yummy' )
  Assert( baked.examples_hash.yummy.texture == 'SANDY' )
end

eg 'looking into an array sub collection' do
  mongo_beans.insert(:name => 'jelly', :texture => 'wibbly', :kind => {:fictional => false},
                     :examples => [
                       {:name => 'red'  , :texture => 'raspberry'},
                       {:name => 'black', :texture => 'shunned'  }
                      ])
                       

  jelly = peace_love_beans.find_one(:name => 'jelly')

  Assert( jelly.examples[0].texture == 'RASPBERRY' )
  Assert( jelly.examples[1].texture == 'SHUNNED'   )
end


eg 'building a blank document' do
  bean = peace_love_beans.build

  Assert( bean.nothing.nil? )
  Assert( bean.kind.healthy == 'healthy' )
end


eg 'saving a hash' do
  h  = { :some_key => 'some value' }
  id = peace_love_beans.insert( h )

  Assert( peace_love_beans.find_one(id).some_key == 'some value' )
end


eg 'the id accessor works in ruby 1.8 & 1.9' do
  Assert( Bean.build(:id => 'abc').id == 'abc' )
end

__END__

eg 'looking into a hash sub collection' do
end

# TODO
eg 'setting the mixin on the collection' do
  PeaceLove['beans'].mixin = Bear
end
