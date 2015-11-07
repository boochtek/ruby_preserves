require "preserves/selection"
require "preserves/mapping"
require "preserves/mapper"


module Preserves
  class Repository

    attr_accessor :model_class

    def initialize(options={})
      self.model_class = options[:model]
    end

    def fetch(primary_key_value)
      select(fetch_query, primary_key_value).only
    end

    def fetch!(primary_key_value)
      select(fetch_query, primary_key_value).only!
    end

    alias_method :[], :fetch

    def query(sql_string, *params)
      pg_result = data_store.exec_params(sql_string, params)
      SQL::ResultSet.new(pg_result)
    end

    def select(sql_string, *params)
      if params && params.last.is_a?(Hash)
        relations = params.pop
      else
        relations = {}
      end
      Selection.new(map(query(sql_string, *params), relations))
    end

    def map(result, relations={})
      mapper.map(result, relations)
    end

  protected

    def mapping(&block)
      @mapping ||= Mapping.new(self, model_class, &block)
    end

  private

    def mapper
      @mapper ||= Mapper.new(@mapping)
    end

    # NOTE: We'll allow overriding this default on a per-repository basis later.
    def data_store
      Preserves.data_store
    end

    def fetch_query
      "SELECT * FROM \"#{mapping.table_name}\" WHERE #{mapping.primary_key} = $1"
    end

  end
end
