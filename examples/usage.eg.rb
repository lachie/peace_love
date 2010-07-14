require 'eg.helper'
require 'angry_hash'
require 'peace_love'


module Kind
  def claws; "dainty" end

  def for_kids?
    fictional? && cartoon?
  end
end

module Bear
  include PeaceLove::Doc
  sub_doc :kind, Kind
  sub_col :lovers, Bear

  def claws; "woah" end
  def liver
    super.upcase
  end
end

eg.setup do
  PeaceLove.db = $db

  @mbears = $db['bears']
  @mbears.remove()

  Bear.collection = 'bears'
  @plbears = PeaceLove['bears']
end
eg.helpers do
  attr_reader :mbears, :plbears
end


eg 'loading a document with a mixin' do
  mbears.insert(:name => 'yogi', :liver => 'pure', :kind => {:fictional => true, :cartoon => true})

  yogi = plbears.find_one(:name => 'yogi')

  Assert( yogi.claws      == 'woah' )
  Assert( yogi.kind.claws == 'dainty' )
  Assert( yogi.name       == 'yogi' )

  Assert( yogi.liver == 'PURE' )
  Assert( yogi.kind.for_kids? )
end


eg 'loading a non-existent doc' do
  b = plbears.find_one(:name => 'bertrand')

  Assert( b.nil? )
end


eg 'wrapping the mongo cursor' do
  mbears.insert(:name => 'yogi'    , :liver => 'pure', :kind => {:fictional => true, :cartoon => true})
  mbears.insert(:name => 'humphrey', :liver => 'cihrrotic', :kind => {:fictional => true, :cartoon => false})

  
  i = 0
  plbears.find.each {|b|

    case i
    when 0
      Assert( b.kind.claws == 'dainty' )
      Assert( b.liver == 'PURE' )
    when 1
      Assert( b.kind.claws == 'dainty' )
      Assert( b.liver == 'CIHRROTIC' )
    end

    i += 1
  }
end


eg 'mixing in to each element of a sub collection' do
  mbears.remove()
  mbears.insert(:name => 'yogi', :liver => 'pure', :kind => {:fictional => true, :cartoon => true}, :lovers => 
                      [
                        {:name => 'mrs. yogi', :liver => 'donated'}, {:name => 'yogi paw', :liver => 'jaundiced'}
                      ])

  yogi = plbears.find_one(:name => 'yogi')

  Assert( yogi.lovers[0].liver == 'DONATED'   )
  Assert( yogi.lovers[1].liver == 'JAUNDICED' )
end


eg 'building a blank doc' do
  yogi = plbears.build

  Assert( yogi.claws      == 'woah' )
  Assert( yogi.kind.claws == 'dainty' )
end


eg 'saving a hash' do
  h = AngryHash[ :somesuch => 'second thing' ]
  id = plbears.insert( h )

  Assert( plbears.find_one(id).somesuch == 'second thing' )
end


eg 'the id accessor works in ruby 1.8 & 1.9' do
  Assert(Bear.build(:id => 'abc').id == 'abc')
end


# TODO
#eg 'setting the mixin on the collection' do
  #PeaceLove['bears'].mixin = Bear
#end
