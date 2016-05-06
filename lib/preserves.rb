require "sequel"
require "preserves/version"
require "preserves/repository"


module Preserves
  def self.repository(options={}, &block)
    repository = Repository.new(options)
    repository.instance_eval(&block)
    repository
  end
end
