require 'rails/generators/erb/scaffold/scaffold_generator'
require 'generators/goma/helpers/helpers'

module Goma
  module Generators
    class ErbGenerator < ::Erb::Generators::ScaffoldGenerator
      hide!
      include Helpers
      source_root File.expand_path('../templates', __FILE__)

      class_option :controller_type, required: true
      class_option :resource_name

      def copy_view_files
        available_view_files.each do |filename|
          template "#{template_dir}/#{filename}", File.join("app/views", controller_file_path, filename)
        end
      end

    protected
      def available_view_files
        Dir.entries(File.expand_path(template_dir, self.class.source_root)).keep_if{|e| e =~ /\.erb$/} - ['.', '..']
      end

      def template_dir
        options[:controller_type]
      end
    end
  end
end
