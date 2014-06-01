# Terminology note: A field is associated with a single row/record. A column pertains to all rows/records.


module Preserves
  class Mapper
    attr_accessor :primary_key
    attr_accessor :name_mappings
    attr_accessor :type_mappings

    def initialize(&block)
      self.primary_key = "id"
      self.name_mappings = {}
      self.type_mappings = {}
      self.instance_eval(&block)
    end

    def column_name_to_attribute_name(column_name)
      name_mappings.fetch(column_name) { column_name }
    end

    def field_value_to_attribute_value(attribute_name, field_value)
      attribute_type = attribute_name_to_attribute_type(attribute_name)
      coerce(field_value, to: attribute_type)
    end

    def attribute_name_to_attribute_type(attribute_name)
      type_mappings.fetch(attribute_name.to_sym) { String }
    end

  protected

    # Note that this works to set or get the primary key.
    def primary_key(key_name = nil)
      @primary_key = key_name unless key_name.nil?
      @primary_key
    end

    def map(*args)
      if args[0].is_a?(Hash)
        database_field_name = args[0].values.first
        model_attribute_name = args[0].keys.first
        self.name_mappings[database_field_name] = model_attribute_name
      elsif args[0].is_a?(Symbol)
        model_attribute_name = args[0]
        database_field_name = args[0].to_s
      end

      if args[1].is_a?(Class)
        self.type_mappings[model_attribute_name] = args[1]
      end
    end

  private

    def coerce(field_value, options={})
      return nil if field_value.nil?

      if options[:to] == Integer
        Integer(field_value)
      else
        field_value
      end
    end

  end
end
