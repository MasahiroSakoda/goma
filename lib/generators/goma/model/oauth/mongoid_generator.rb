require 'rails/generators/named_base'
require 'generators/goma/helpers/orm_helpers.rb'
require 'generators/goma/helpers/mongoid_helpers.rb'
require 'generators/goma/model/oauth/common.rb'

module Goma
  module Generators
    module Model
      module OAuth
        class MongoidGenerator < ::Rails::Generators::NamedBase
          @namespace      = 'goma:model:oauth:mongoid'
          @generator_name = 'mongoid'
          hide!
          include Goma::Generators::Helpers::OrmHelpers
          include Goma::Generators::Helpers::MongoidHelpers
          include Goma::Generators::Model::OAuth::Common

          def generate_model
            super
          end

          def inject_goma_content
            super
          end

        private
          def mongoid_contents
            "#{field_data}\n#{index_data}"
          end
        end
      end
    end
  end
end

