require 'rails/generators/mailer/mailer_generator'
require 'generators/goma/helpers/mailer_helpers'

module Goma
  module Generators
    class MailerGenerator < Rails::Generators::MailerGenerator
      include MailerHelpers
      source_root File.expand_path('../templates', __FILE__)

      class_option :resource_name

      hook_for :template_engine, in: 'goma:mailer'
    end
  end
end
