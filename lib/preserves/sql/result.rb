module Preserves
  module SQL
    class Result
      def initialize(pg_result)
        @pg_result = pg_result
      end

      def rows
        @pg_result.ntuples == 0 ? @pg_result.cmd_tuples : @pg_result.ntuples
      end
    end
  end
end