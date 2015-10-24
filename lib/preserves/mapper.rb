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

    # TODO: This obviously needs a lot of refactoring.
    # TODO: Don't throw exceptions inside iterations; check things before the iterations.
    def map_result_to_objects(result, relations={})
      result.map do |record|
        object = model_class.new
        record.each_pair do |column_name, field_value|
          attribute_name = column_name_to_attribute_name(column_name)
          if object.respond_to?("#{attribute_name}=")
            object.send("#{attribute_name}=", field_value_to_attribute_value(attribute_name, field_value))
          else
            # Probably DON'T want to raise an error here; we may have fields in the DB that we want the app to ignore.
            # raise Preserves::MissingModelSetter.new(model_class, attribute_name)
          end
        end
        relations.each do |relation_name, relation_result|
          if object.respond_to?("#{relation_name}=")
            relation_settings = has_many_mappings.fetch(relation_name) { fail "Don't know how to map #{relation_name} relation." }
            relation_repo = relation_settings.fetch(:repository) # TODO: Need a default.
            relation_foreign_key = relation_settings.fetch(:foreign_key) { "#{model_class.to_s.downcase}_id" }
            # TODO: Should we remove the foreign key from the result set? I don't think we have to, due to the way we set attributes.
            relation_results_for_this_object = SQL::Result.new(relation_result.select{|r| r[relation_foreign_key] == record.fetch(primary_key)}) # TODO: Make each work so we don't need the new here.
            object.send("#{relation_name}=", relation_repo.map(relation_results_for_this_object))
          else
            # TODO: Raise an error here, since we're explicitly asking to set this relation.
            # raise Preserves::MissingModelSetter.new(model_class, relation_name)
          end
        end
        object
      end
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
