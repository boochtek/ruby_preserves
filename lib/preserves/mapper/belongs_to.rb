require "preserves/mapper/relation"

module Preserves
  class Mapper
    class BelongsTo < Relation

      def map!
        assign_attribute(object, relation_name, relation_repo.map_one(relation_result_for_this_object))
      end

      def relation_result_for_this_object
        @relation_result_for_this_object ||= relation_result_set.where(relation_repo.mapping.primary_key => record.fetch(relation_foreign_key)).first
      end

      def relation_foreign_key
        @relation_foreign_key ||= relation_settings.fetch(:foreign_key){ "#{relation_name.downcase}_id" }.to_sym
      end

      def relation_settings
        @relation_settings ||= mapping.belongs_to_mappings.fetch(relation_name)
      end

    end
  end
end
