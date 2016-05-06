module Preserves
  class Mapper
    class Relation

      attr_reader :object, :record, :relation_name, :relation_result_set, :mapping

      def initialize(object, record, relation_name, relation_result_set, mapping)
        @object = object
        @record = record
        @relation_name = relation_name
        @relation_result_set = relation_result_set
        @mapping = mapping
      end

      def relation_repo
        @relation_repo ||= relation_settings.fetch(:repository) # TODO: Need a default.
      end

      def assign_attribute(object, attribute_name, value)
        object.send("#{attribute_name}=", value)
      end

    end
  end
end
