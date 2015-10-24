module Preserves
  module SQL
    class ResultSet

      include Enumerable

      def initialize(pg_result)
        @pg_result = pg_result
      end

      def size
        @pg_result.ntuples == 0 ? @pg_result.cmd_tuples : @pg_result.ntuples
      end

      def each(&block)
        @pg_result.each(&block)
      end

      def only
        fail "expected only 1 result" if size > 1
        self
      end

      def only!
        fail "expected exactly 1 result" if size != 1
        self
      end

      alias_method :one, :only
      alias_method :one!, :only!

    end
  end
end
