module Preserves
  class Mapper
    class BelongsTo

      attr_reader :object, :record, :relation_name, :relation_result_set, :mapping

      def initialize(object, record, relation_name, relation_result_set, mapping)
        @object = object
        @record = record
        @relation_name = relation_name
        @relation_result_set = relation_result_set
        @mapping = mapping
      end

      def map!
        assign_attribute(object, relation_name, relation_repo.map_one(relation_result_for_this_object))
      end

      def relation_settings
        @relation_settings ||= mapping.belongs_to_mappings.fetch(relation_name)
      end

      def relation_repo
        @relation_repo ||= relation_settings.fetch(:repository) # TODO: Need a default.
      end

      def relation_foreign_key
        @relation_foreign_key ||= relation_settings.fetch(:foreign_key) { "#{relation_name.downcase}_id" }
      end

      def relation_result_for_this_object
        @relation_result_for_this_object ||= relation_result_set.find{ |r| r[relation_repo.mapping.primary_key] == record.fetch(relation_foreign_key) }
      end

      def assign_attribute(object, attribute_name, value)
        object.send("#{attribute_name}=", value)
      end

    end
  end
end
