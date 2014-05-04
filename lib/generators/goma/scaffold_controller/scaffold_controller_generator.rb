require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
require 'generators/goma/helpers/helpers'

module Goma
  module Generators
    class ScaffoldControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
      include Helpers
      source_root File.expand_path('../templates', __FILE__)

      class_option :controller_type, required: true
      class_option :resource_name

      # TODO
      # jbuilder templates are not implemented yet. Therefore, set default to false.
      class_option :jbuilder, default: false

      def create_controller_files
        template "#{options[:controller_type]}_controller.rb", File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      hook_for :template_engine, in: 'goma'
    end
  end
end
