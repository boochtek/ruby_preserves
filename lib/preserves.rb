require "preserves/version"
require "preserves/repository"
require "preserves/sql"


module Preserves
  def self.repository(options={}, &block)
    repository = Repository.new(options)
    repository.instance_eval(&block)
    repository
  end

  def self.data_store
    SQL.connection(dbname: "preserves_test")
  end
end
