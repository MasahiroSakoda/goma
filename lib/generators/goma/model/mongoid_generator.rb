require 'rails/generators/named_base'
require 'generators/goma/helpers/orm_helpers.rb'
require 'generators/goma/helpers/mongoid_helpers.rb'
require 'generators/goma/model/common.rb'

module Goma
  module Generators
    module Model
      class MongoidGenerator < ::Rails::Generators::NamedBase
        hide!
        include Goma::Generators::Helpers::OrmHelpers
        include Goma::Generators::Helpers::MongoidHelpers
        include Goma::Generators::Model::Common

        def generate_model
          super
        end

        def inject_goma_content
          super
        end

      private
        def mongoid_contents
          "include Goma::Models\n#{model_contents}\n#{field_data}\n#{index_data}"
        end
      end
    end
  end
end

