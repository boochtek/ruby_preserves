require "preserves/selection"
require "preserves/mapping"
require "preserves/mapper"


module Preserves
  class Repository

    attr_accessor :model_class
    attr_accessor :dataset

    def initialize(options={})
      self.model_class = options[:model]
      self.dataset = options[:dataset]
    end

    def all
      map(dataset)
    end

    def fetch(primary_key_value)
      map(dataset.where(fetch_query(primary_key_value))).only
    end

    def fetch!(primary_key_value)
      map(dataset.where(fetch_query(primary_key_value))).only!
    end

    alias_method :[], :fetch

    def map(result, relations={})
      Selection.new(mapper.map(result, relations))
    end

    def map_one(result, relations={})
      mapper.map_one(result, relations)
    end

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

    def fetch_query(primary_key_value)
      { mapping.primary_key.to_sym => primary_key_value}
    end

  end
end
