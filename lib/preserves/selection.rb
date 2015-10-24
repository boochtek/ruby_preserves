module Preserves
  class Selection

    attr_accessor :domain_objects

    def initialize(domain_objects)
      self.domain_objects = domain_objects
    end

    def each(&block)
      domain_objects.each(&block)
    end

    def size
      domain_objects.size
    end

    def first
      domain_objects.first
    end

    def second
      domain_objects.second
    end

    def last
      domain_objects.last
    end

    def only
      fail "expected only 1 result" if size > 1
      domain_objects.first
    end

    def only!
      fail "expected exactly 1 result" if size != 1
      domain_objects.first
    end

    alias_method :one, :only
    alias_method :one!, :only!

    def [](index)
      domain_objects[index]
    end

  end
end
