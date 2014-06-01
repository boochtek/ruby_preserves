require "preserves/mapper"


module Preserves
  class Repository
    attr_accessor :model_class
    attr_accessor :mapper

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
      (0..pg_result.ntuples-1).map{|n| hash_to_model_object(pg_result[n])}
    end

  protected

    def mapping(&block)
      self.mapper = Mapper.new(&block)
    end

  private

    def hash_to_model_object(hash)
      object = model_class.new
      hash.each_pair do |column_name, field_value|
        attribute_name = mapper.column_name_to_attribute_name(column_name)
        if object.respond_to?("#{attribute_name}=")
          object.send("#{attribute_name}=", mapper.field_value_to_attribute_value(attribute_name, field_value))
        else
          # Not sure if we want to raise an error here; we may have foreign keys and such in the database but not the model.
          # raise Preserves::MissingModelSetter.new(model_class, attribute_name)
        end
      end
      object
    end

  end
end
