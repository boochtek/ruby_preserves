require "preserves/mapper/relation"

module Preserves
  class Mapper
    class HasMany < Relation

      def map!
        assign_attribute(object, relation_name, relation_repo.map(relation_results_for_this_object))
      end

      def relation_results_for_this_object
        @relation_results_for_this_object ||= relation_result_set.where(relation_foreign_key => record.fetch(mapping.primary_key))
      end

      def relation_foreign_key
        @relation_foreign_key ||= relation_settings.fetch(:foreign_key){ "#{mapping.model_class.to_s.downcase}_id" }.to_sym
      end

      def relation_settings
        @relation_settings ||= mapping.has_many_mappings.fetch(relation_name)
      end

    end
  end
end
