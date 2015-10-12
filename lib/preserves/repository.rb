require "preserves/mapper"


module Preserves
  class Repository
    attr_accessor :model_class
    attr_accessor :mapper

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

  protected

    def mapping(&block)
      self.mapper = Mapper.new(self, model_class, &block)
    end

  private

    # NOTE: We'll allow overriding this default on a per-repository basis later.
    def data_store
      Preserves.data_store
    end

  end
end
