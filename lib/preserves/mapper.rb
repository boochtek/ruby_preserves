module Preserves
  class Mapper
    def query(sql_string)
      pg_result = SQL.connection(dbname: "preserves_test").exec(sql_string)
      SQL::Result.new(pg_result)
    end
  end
end
