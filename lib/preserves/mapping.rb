module Preserves
  class Mapping

    attr_accessor :repository
    attr_accessor :model_class
    attr_accessor :name_mappings
    attr_accessor :type_mappings
    attr_accessor :has_many_mappings
    attr_accessor :belongs_to_mappings

    def initialize(repository, model_class, &block)
      table_name pluralize(model_class.name.downcase)
      primary_key "id"
      self.repository = repository
      self.model_class = model_class
      self.name_mappings = {}
      self.type_mappings = {}
      self.has_many_mappings = {}
      self.belongs_to_mappings = {}
      self.instance_eval(&block)
    end

    # Note that this works to set or get the table name.
    # TODO: We don't want to allow publicly setting this, but we need to publicly get it.
    def table_name(name=nil)
      @table_name = name unless name.nil?
      @table_name
    end

    # Note that this works to set or get the primary key.
    # TODO: We don't want to allow publicly setting this, but we need to publicly get it.
    def primary_key(key_name=nil)
      @primary_key = key_name unless key_name.nil?
      @primary_key
    end

  protected

    def map(*args)
      if args[0].is_a?(Hash)
        database_field_name = args[0].values.first
        model_attribute_name = args[0].keys.first
        self.name_mappings[database_field_name] = model_attribute_name
      elsif args[0].is_a?(Symbol)
        model_attribute_name = args[0]
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

    def pluralize(string)
      case string
      when /(x|ch|ss|sh)$/i
        string + "es"
      when /s$/i
        string
      else
        string + "s"
      end
    end

  end
end
