module Preserves
  module SQL
    class Result

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

    end
  end
end
