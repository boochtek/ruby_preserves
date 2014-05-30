require "pg"
require "preserves/sql/result"


module Preserves
  module SQL
    def self.connection(*args)
      @connection ||= {}
      @connection[args] ||= PG.connect(*args)
    end
  end
end
