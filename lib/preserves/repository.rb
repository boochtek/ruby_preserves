module Preserves
  class Repository
    def initialize(*options)
    end

    def query(sql_string)
      pg_result = SQL.connection(dbname: "preserves_test").exec(sql_string)
      SQL::Result.new(pg_result)
    end

    def select(sql_string)
      pg_result = SQL.connection(dbname: "preserves_test").exec(sql_string)
      fields = pg_result.fields
      (0..pg_result.ntuples-1).map{|n| hash_to_object(pg_result[n])}
    end

  private

    def hash_to_object(hash)
      object = User.new
      hash.each_pair do |column_name, field_value|
        if object.respond_to?("#{column_name}=")
          object.send("#{column_name}=", field_value)
        end
      end
      object
    end
  end
end
