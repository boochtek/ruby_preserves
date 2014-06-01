module Preserves
  class Mapper
    attr_accessor :name_mappings

    def initialize(&block)
      self.name_mappings = {}
      self.instance_eval(&block)
    end

    def column_name_to_attribute_name(column_name)
      name_mappings.fetch(column_name) { column_name }
    end

  protected

    def map(*args)
      if args[0].is_a?(Hash)
        database_field_name = args[0].values.first
        model_attribute_name = args[0].keys.first
        self.name_mappings[database_field_name] = model_attribute_name
      end
    end
  end
end
