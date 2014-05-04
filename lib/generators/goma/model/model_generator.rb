require 'rails/generators/rails/model/model_generator'

module Goma
  module Generators
    class ModelGenerator < Rails::Generators::ModelGenerator
      desc "Generates a model with the given NAME (if one does not exist) with goma " +
           "configuration and a migration file"

      hook_for :orm, required: true, in: 'goma:model'
    end
  end
end
