require 'set'
require 'rails/generators/active_record'
require 'generators/goma/helpers/orm_helpers.rb'
require 'generators/goma/helpers/active_record_helpers.rb'
require 'generators/goma/model/common.rb'

module Goma
  module Generators
    module Model
      class ActiveRecordGenerator < ::ActiveRecord::Generators::Base
        hide!
        argument :attributes, type: :array, default: [], banner: 'field:type field:type'

        include Goma::Generators::Helpers::OrmHelpers
        include Goma::Generators::Helpers::ActiveRecordHelpers
        include Goma::Generators::Model::Common
        source_root File.expand_path('../templates', __FILE__)

        def copy_goma_migration
          super
        end

        def generate_model
          super
        end

        def inject_goma_content
          class_path = if namespaced?
                         class_name.to_s.split("::")
                       else
                         [class_name]
                       end

          indent_depth = class_path.size

          content = indent(indent_depth, model_contents)
          inject_into_class(model_path, class_path.last, content) if model_exists?
        end

      private
        def adding_migration_name
          "add_goma_to_#{table_name}"
        end

        def migration_data
          indent(3, field_data)
        end

        def index_data
          indent(2, super)
        end
      end
    end
  end
end
