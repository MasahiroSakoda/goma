module Goma
  module Generators
    module Model
      class OAuthGenerator < Rails::Generators::NamedBase
        @namespace      = 'goma:model:oauth'
        @generator_name = 'oauth'


        include Rails::Generators::ResourceHelpers

        desc "Generates a model with the given NAME (if one does not exist) with goma " +
             "oauth configuration and a migration file"

        hook_for :orm, in: 'goma:model:oauth'
      end
    end
  end
end
