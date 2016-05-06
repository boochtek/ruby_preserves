require "sequel"
require "preserves/version"
require "preserves/repository"


module Preserves
  def self.repository(model_class, dataset, &block)
    repository = Repository.new(model_class, dataset)
    repository.instance_eval(&block)
    repository
  end
end
