module Preserves
  module SQL
    class Result

      def initialize(pg_result)
        @pg_result = pg_result
      end

      def size
        @pg_result.ntuples == 0 ? @pg_result.cmd_tuples : @pg_result.ntuples
      end

      def to_objects(mapper)
        @pg_result.map do |record|
          object = mapper.model_class.new
          record.each_pair do |column_name, field_value|
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
  end
end
