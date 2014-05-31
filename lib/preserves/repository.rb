module Preserves
  class Repository
    attr_accessor :model_class

    def initialize(options={})
      self.model_class = options[:model]
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
      object = model_class.new
      hash.each_pair do |column_name, field_value|
        if object.respond_to?("#{column_name}=")
          object.send("#{column_name}=", field_value)
        end
      end
      object
    end
  end
end
