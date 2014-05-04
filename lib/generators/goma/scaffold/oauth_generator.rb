require 'rails/generators/rails/scaffold/scaffold_generator'

module Goma
  module Generators
    module Scaffold
      class OAuthGenerator < Rails::Generators::ScaffoldGenerator
        @namespace      = 'goma:scaffold:oauth'
        @generator_name = 'oauth'

        def initialize(args, *options)
          options[0] << '--controller-type=oauth'
          super
        end

        hook_for :orm, required: true, in: 'goma:model:oauth'

        hook_for :resource_route,      required: true, in: 'goma'
        hook_for :scaffold_controller, required: true, in: 'goma'
      end
    end
  end
end
