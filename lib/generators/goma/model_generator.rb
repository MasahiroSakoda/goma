module Goma
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      desc "Generates a model with the given NAME (if one does not exist) with goma " +
           "configuration and a migration file"

      hook_for :orm, in: 'goma:model'
    end
  end
end
