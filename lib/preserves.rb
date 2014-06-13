require "preserves/version"
require "preserves/repository"
require "preserves/sql"


module Preserves
  def self.repository(options={}, &block)
    repository = Repository.new(options)
    repository.instance_eval(&block)
    repository
  end

  def self.data_store=(connection)
    @data_store = connection
  end

  def self.data_store
    @data_store or raise "You must define a default data store"
  end

  def self.PostgreSQL(db_name)
    SQL.connection(dbname: db_name)
  end
end
