require 'rails/generators/rails/scaffold/scaffold_generator'

module Goma
  module Generators
    module Scaffold
      class UserGenerator < Rails::Generators::ScaffoldGenerator
        def initialize(args, *options)
          options[0] << '--controller-type=user'
          super
        end

        hook_for :orm, required: true, in: 'goma:model'

        hook_for :resource_route,      required: true, in: 'goma'
        hook_for :scaffold_controller, required: true, in: 'goma'
      end
    end
  end
end
