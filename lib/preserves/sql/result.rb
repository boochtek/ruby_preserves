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

      # TODO: This obviously needs a lot of refactoring.
      # TODO: Don't throw exceptions inside iterations; check things before the iterations.
      def to_objects(mapper, relations={})
        @pg_result.map do |record|
          object = mapper.model_class.new
          record.each_pair do |column_name, field_value|
            attribute_name = mapper.column_name_to_attribute_name(column_name)
            if object.respond_to?("#{attribute_name}=")
              object.send("#{attribute_name}=", mapper.field_value_to_attribute_value(attribute_name, field_value))
            else
              # Probably DON'T want to raise an error here; we may have fields in the DB that we want the app to ignore.
              # raise Preserves::MissingModelSetter.new(model_class, attribute_name)
            end
          end
          relations.each do |relation_name, relation_result|
            if object.respond_to?("#{relation_name}=")
              relation_settings = mapper.has_many_mappings.fetch(relation_name) { raise "Don't know how to map #{relation_name} relation." }
              relation_repo = relation_settings.fetch(:repository) # TODO: Need a default.
              relation_foreign_key = relation_settings.fetch(:foreign_key) { "#{mapper.model_class.to_s.downcase}_id" }
              # TODO: Should we remove the foreign key from the result set? I don't think we have to, due to the way we set attributes.
              relation_results_for_this_object = SQL::Result.new(relation_result.select{|r| r[relation_foreign_key] == record.fetch(mapper.primary_key)}) # TODO: Make each work so we don't need the new here.
              object.send("#{relation_name}=", relation_results_for_this_object.to_objects(relation_repo.mapper))
            else
              # TODO: Raise an error here, since we're explicitly asking to set this relation.
              # raise Preserves::MissingModelSetter.new(model_class, relation_name)
            end
          end
          object
        end
      end

    end
  end
end
