module Preserves
  class Mapper
    class HasMany

      attr_reader :object, :record, :relation_name, :relation_result_set, :mapping

      def initialize(object, record, relation_name, relation_result_set, mapping)
        @object = object
        @record = record
        @relation_name = relation_name
        @relation_result_set = relation_result_set
        @mapping = mapping
      end

      def map!
        assign_attribute(object, relation_name, relation_repo.map(relation_results_for_this_object))
      end

      def relation_settings
        @relation_settings ||= mapping.has_many_mappings.fetch(relation_name)
      end

      def relation_repo
        @relation_repo ||= relation_settings.fetch(:repository) # TODO: Need a default.
      end

      def relation_foreign_key
        @relation_foreign_key ||= relation_settings.fetch(:foreign_key) { "#{mapping.model_class.to_s.downcase}_id" }
      end

      def relation_results_for_this_object
        @relation_results_for_this_object ||= relation_result_set.select{ |r| r[relation_foreign_key] == record.fetch(mapping.primary_key) }
      end

      def assign_attribute(object, attribute_name, value)
        object.send("#{attribute_name}=", value)
      end

    end
  end
end
