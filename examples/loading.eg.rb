require 'eg.helper'
require 'angry_hash'
require 'peace_love'

eg.setup do
  PeaceLove.db = $db
end

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

eg 'loading doc' do
  $db['bears'].remove()
  $db['bears'].insert(:name => 'yogi', :liver => 'pure', :kind => {:fictional => true, :cartoon => true})

  PeaceLove['bears'].mixin = Bear
  yogi = PeaceLove['bears'].find_one(:name => 'yogi')
  Show(yogi.claws)
  Show(yogi.name)

  Assert(yogi.liver == 'PURE')
  Show(yogi.kind.for_kids?)
end

eg 'loading a non-existant doc' do
  $db['bears'].remove()
  PeaceLove['bears'].mixin = Bear
  b = PeaceLove['bears'].find_one(:name => 'bertrand')
  Assert( b.nil? )
end

eg 'wrapping the cursor' do
  $db['bears'].remove()
  $db['bears'].insert(:name => 'yogi'    , :liver => 'pure', :kind => {:fictional => true, :cartoon => true})
  $db['bears'].insert(:name => 'humphrey', :liver => 'cihrrotic', :kind => {:fictional => true, :cartoon => false})
  
  i = 0
  PeaceLove['bears'].find.each {|b|
    Show(b)
    if i == 0
      Assert(b.liver == 'PURE')
    elsif i == 1
      Assert(b.liver == 'CIHRROTIC')
    end
    i += 1
  }
end

eg 'sub collection' do
  $db['bears'].remove()
  $db['bears'].insert(:name => 'yogi', :liver => 'pure', :kind => {:fictional => true, :cartoon => true}, :lovers => 
                      [
                        {:name => 'mrs. yogi', :liver => 'donated'}, {:name => 'yogi paw', :liver => 'jaundiced'}
                      ])

  yogi = PeaceLove['bears'].find_one(:name => 'yogi')

  Show(yogi.lovers)
  Assert(yogi.lovers[0].liver == 'DONATED')
  Assert(yogi.lovers[1].liver == 'JAUNDICED')
end

eg 'blank doc' do
  PeaceLove['bears'].mixin = Bear
  yogi = PeaceLove['bears'].build
  yogi.claws
end

eg 'saving object' do
  h = AngryHash[ :somesuch => 'second thing' ]
  id = PeaceLove['bears'].insert( h )
  PeaceLove['bears'].find_one(id)
end
