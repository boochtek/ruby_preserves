# Terminology note: A field is associated with a single row/record. A column pertains to all rows/records.


module Preserves
  class Mapper
    attr_accessor :repository
    attr_accessor :model_class
    attr_accessor :primary_key
    attr_accessor :name_mappings
    attr_accessor :type_mappings
    attr_accessor :has_many_mappings
    attr_accessor :belongs_to_mappings

    def initialize(repository, model_class, &block)
      self.repository = repository
      self.model_class = model_class
      self.primary_key = "id"
      self.name_mappings = {}
      self.type_mappings = {}
      self.has_many_mappings = {}
      self.belongs_to_mappings = {}
      self.instance_eval(&block)
    end

    def column_name_to_attribute_name(column_name)
      name_mappings.fetch(column_name) { column_name }
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
      type_mappings.fetch(attribute_name.to_sym) { String }
    end

    # Note that this works to set or get the primary key.
    # TODO: We don't want to allow publicly setting this, but we need to publicly get it until we move to_objects into Mapper.
    def primary_key(key_name = nil)
      @primary_key = key_name unless key_name.nil?
      @primary_key
    end

  protected

    def primary_key_attribute
      column_name_to_attribute_name(primary_key)
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

    def has_many(related_attribute_name, options)
      self.has_many_mappings[related_attribute_name] = options
    end

    def belongs_to(related_attribute_name, options)
      self.belongs_to_mappings[related_attribute_name] = options
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
