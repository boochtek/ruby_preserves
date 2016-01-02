# Terminology note: A field is associated with a single row/record. A column pertains to all rows/records.

require "preserves/mapping"
require "preserves/mapper/has_many"
require "preserves/mapper/belongs_to"


module Preserves
  class Mapper

    attr_accessor :mapping

    def initialize(mapping)
      self.mapping = mapping
    end

    def map(result, relations={})
      result.map do |record|
        map_one(record, relations)
      end
    end

    def map_one(record, relations={})
      mapping.model_class.new.tap do |object|
        map_attributes(object, record)
        map_relations(object, record, relations)
      end
    end

  protected

    def primary_key_attribute
      column_name_to_attribute_name(mapping.primary_key)
    end

  private

    def map_attributes(object, record)
      record.each_pair do |column_name, field_value|
        attribute_name = column_name_to_attribute_name(column_name)
        if object.respond_to?("#{attribute_name}=")
          object.send("#{attribute_name}=", field_value_to_attribute_value(attribute_name, field_value))
        end
      end
    end

    def column_name_to_attribute_name(column_name)
      mapping.name_mappings.fetch(column_name.to_sym) { column_name }
    end

    def field_value_to_attribute_value(attribute_name, field_value)
      attribute_type = attribute_name_to_attribute_type(attribute_name)
      coerce(field_value, to: attribute_type)
    end

    def attribute_value_to_field_value(attribute_name, attribute_value)
      attribute_type = attribute_name_to_attribute_type(attribute_name)
      uncoerce(attribute_value, to: attribute_type)
    end

    def attribute_name_to_attribute_type(attribute_name)
      mapping.type_mappings.fetch(attribute_name.to_sym) { String }
    end

    def map_relations(object, record, relations)
      has_many_relations = relations.select{ |k, _v| mapping.has_many_mappings.keys.include?(k) }
      map_has_many_relations(object, record, has_many_relations)
      belongs_to_relations = relations.select{ |k, _v| mapping.belongs_to_mappings.keys.include?(k) }
      map_belongs_to_relations(object, record, belongs_to_relations)
      # TODO: Raise an exception if any of the relations weren't found in any of the relation mappings.
    end

    def map_has_many_relations(object, record, relations)
      # TODO: Ensure that there's a setter for every relation_name before we iterate through the relations.
      relations.each do |relation_name, relation_result_set|
        Mapper::HasMany.new(object, record, relation_name, relation_result_set, mapping).map!
      end
    end

    def map_belongs_to_relations(object, record, relations)
      # TODO: Ensure that there's a setter for every relation_name before we iterate through the relations.
      relations.each do |relation_name, relation_result_set|
        Mapper::BelongsTo.new(object, record, relation_name, relation_result_set, mapping).map!
      end
    end

    def coerce(field_value, options={})
      return nil if field_value.nil?

      if options[:to] == Integer
        Integer(field_value)
      else
        field_value
      end
    end

    def uncoerce(attribute_value, options={})
      return "NULL" if attribute_value.nil?

      if options[:to] == String
        "'#{attribute_value}'"
      else
        attribute_value.to_s
      end
    end

  end
end
