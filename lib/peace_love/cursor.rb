module PeaceLove
  class Cursor
    include Enumerable

    attr_reader :mongo_cursor

    def initialize(cursor,collection)
      @collection = collection
      @cursor     = @mongo_cursor = cursor
    end

    def each
      @cursor.each {|doc| yield @collection.__wrap(doc)}
    end

    def next_document
      @collection.__wrap( @cursor.next_document )
    end

    def to_a
      @cursor.to_a.map {|doc| @collection.__wrap(doc)}
    end

    (Mongo::Cursor.instance_methods - self.instance_methods).each do |name|
      next if name[-1] == ?=
      class_eval "def #{name}(*args,&block); @cursor.#{name}(*args,&block) end" unless method_defined?(name)
    end
  end
end


