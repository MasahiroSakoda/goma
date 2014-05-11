require 'rails/generators/rails/resource_route/resource_route_generator'
require 'generators/goma/helpers/helpers'

module Goma
  module Generators
    class ResourceRouteGenerator < ::Rails::Generators::ResourceRouteGenerator
      hide!
      include Helpers

      class_option :controller_type

      def add_resource_route
        return if options[:actions].present?

        # iterates over all namespaces and opens up blocks
        regular_class_path.each_with_index do |namespace, index|
          write("namespace :#{namespace} do", index + 1)
        end

        # inserts the primary resource
        write(resource_string, route_length + 1)

        # ends blocks
        regular_class_path.each_index do |index|
          write("end", route_length - index)
        end

        # route prepends two spaces onto the front of the string that is passed, this corrects that
        route route_string[2..-1]
      end

    private
      def write(str, indent)
        str.each_line do |line|
          route_string << "#{"  " * indent}#{line}"
        end
        route_string << "\n"
      end

      def resource_string
        "#{resource_definition}#{restriction}#{appending_string}"
      end

      def resource_definition
        if options[:controller_type] == 'session'
          "resource :#{file_name.singularize}"
        else
          "resources :#{file_name.pluralize}"
        end
      end

      def restriction
        case options[:controller_type]
        when 'session'
          ', only: [:new, :create, :destroy]'
        when 'confirmation'
          ', only: [:new, :create]'
        when 'password'
          ', only: [:new, :create, :edit, :update]'
        when 'unlock'
          ', only: [:show, :new, :create,]'
        when 'oauth'
          ', only: [:create]'
        else
          ''
        end
      end

      def appending_string
        if options[:controller_type] == 'confirmation' && goma_config.modules.include?(:confirmable)
          strings = []
          strings << ' do'
          strings << '  get :activate, on: :member'
          strings << '  get :confirm,  on: :member' if goma_config.email_confirmation_enabled
          strings << 'end'
          strings.join("\n")
        elsif options[:controller_type] == 'oauth'
          "\nget '/auth/:provider/callback', to: '#{file_name.pluralize}#create'"
        end
      end
    end
  end
end
