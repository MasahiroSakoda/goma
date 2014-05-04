require 'rails/generators/rails/scaffold/scaffold_generator'

module Goma
  module Generators
    module Scaffold
      class PasswordGenerator < Rails::Generators::ScaffoldGenerator
        def initialize(args, *options)
          options[0] << '--controller-type=password'
          super
        end

        remove_hook_for :orm

        hook_for :resource_route,      required: true, in: 'goma'
        hook_for :scaffold_controller, required: true, in: 'goma'
      end
    end
  end
end
