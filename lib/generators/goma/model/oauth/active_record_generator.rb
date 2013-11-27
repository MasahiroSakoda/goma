require 'rails/generators/active_record'
require 'generators/goma/helpers/orm_helpers.rb'
require 'generators/goma/helpers/active_record_helpers.rb'
require 'generators/goma/model/oauth/common.rb'

module Goma
  module Generators
    module Model
      module OAuth
        class ActiveRecordGenerator < ::ActiveRecord::Generators::Base
          @namespace      = 'goma:model:oauth:active_record'
          @generator_name = 'active_record'
          hide!

          argument :attributes, type: :array, default: [], banner: 'field:type field:type'

          include Goma::Generators::Helpers::OrmHelpers
          include Goma::Generators::Helpers::ActiveRecordHelpers
          include Goma::Generators::Model::OAuth::Common
          source_root File.expand_path('../../../templates', __FILE__)

          def copy_goma_migration
            super
          end

          def generate_model
            super
          end

        private
          def adding_migration_name
            "add_oauth_columns_to_#{table_name}"
          end

          def migration_data
            content = define_field_name(:belongs_to, scope) + "\n" + field_data
            indent(3, content)
          end

          def index_data
            indent(2, super)
          end
        end
      end
    end
  end
end
