require 'eg.helper'
require 'angry_hash'

eg.setup do
  @col = $db['loading']
  @col.remove()
end

module Customiser
  def another_thing
    self.somesuch.upcase
  end
end

eg 'loading objects' do
  @col.insert(:somesuch => 'and overmore')

  h = AngryHash[ @col.find(:somesuch => 'and overmore').first ]
  h.extend Customiser

  Show( h.somesuch )
  Show( h.another_thing )
  Show( h )



  #PeaceLove.db = $db
  #PeaceLove['loading']
end

eg 'saving object' do
  h = AngryHash[ :somesuch => 'second thing' ]

  @col.insert( h )
  
  hh = @col.find_one
  
end
