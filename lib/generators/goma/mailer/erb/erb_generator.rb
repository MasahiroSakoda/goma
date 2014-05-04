require 'rails/generators/erb/mailer/mailer_generator'
require 'generators/goma/helpers/mailer_helpers'

module Goma
  module Generators
    module Mailer
      class ErbGenerator < ::Erb::Generators::MailerGenerator
        hide!
        include MailerHelpers
        source_root File.expand_path('../templates', __FILE__)

        class_option :resource_name

        def copy_goma_view_files
          base_path = File.join("app/views", class_path, file_name)

          goma_actions.each do |action, _|
            @action = action
            formats.each do |format|
              @path = File.join(base_path, filename_with_extensions(action, format))
              template filename_with_extensions(action, format), @path
            end
          end
        end

      protected
        if Rails.version < "4.1"
          def formats
            [format]
          end

          def filename_with_extensions(name, format=self.format)
            [name, format, handler].compact.join(".")
          end
        end
      end
    end
  end
end
