require "preserves/mapping"
require "preserves/mapper"


module Preserves
  class Repository

    attr_accessor :model_class

    def initialize(options={})
      self.model_class = options[:model]
    end

    def query(sql_string)
      pg_result = data_store.exec(sql_string)
      SQL::Result.new(pg_result)
    end

    def select(sql_string)
      pg_result = data_store.exec(sql_string)
      SQL::Result.new(pg_result)
    end

    def map(result, relations={})
      mapper.map_result_to_objects(result, relations)
    end

  protected

    def mapping(&block)
      @mapping = Mapping.new(self, model_class, &block)
    end

  private

    def mapper
      @mapper ||= Mapper.new(@mapping)
    end

    # NOTE: We'll allow overriding this default on a per-repository basis later.
    def data_store
      Preserves.data_store
    end

  end
end
