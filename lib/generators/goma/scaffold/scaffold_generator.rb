require 'rails/generators'
require 'rails/generators/named_base'
require 'generators/goma/helpers/helpers'

module Goma
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      class_option :include_scope_name_into_controller_name, type: :boolean, aliases: ['--is'],
        desc: 'If you prefer UserSessionsController to SessionsController for example'

      def initialize(*)
        super
        Helpers.include_scope_name_into_controller_name = options[:include_scope_name_into_controller_name]
      end

      def generate_scaffold_user
        log behavior, headline('goma:scaffold:user')
        Rails::Generators.invoke "goma:scaffold:user", [name_for_sub(:user), *args_for_sub], behavior: behavior
      end

      def generate_scaffold_session
        if goma_config.modules.include? :password_authenticatable
          log behavior, headline('goma:scaffold:session')
         Rails::Generators.invoke "goma:scaffold:session", [name_for_sub(:session), *args_for_sub], behavior: behavior
        end
      end

      def generate_scaffold_confirmation
        if goma_config.modules.include? :confirmable
          log behavior, headline('goma:scaffold:confirmation')
          Rails::Generators.invoke "goma:scaffold:confirmation", [name_for_sub(:confirmation), *args_for_sub], behavior: behavior
        end
      end

      def generate_scaffold_password
        if goma_config.modules.include? :recoverable
          log behavior, headline('goma:scaffold:password')
          Rails::Generators.invoke "goma:scaffold:password", [name_for_sub(:password), *args_for_sub], behavior: behavior
        end
      end

      def generate_scaffold_unlock
        if goma_config.modules.include?(:lockable) && goma_config.unlock_strategies.include?(:email)
          log behavior, 'goma:scaffold:unlock'
          Rails::Generators.invoke "goma:scaffold:unlock", [name_for_sub(:unlock), *args_for_sub], behavior: behavior
        end
      end

      def generate_scaffold_oauth
        if goma_config.modules.include?(:omniauthable)
          log behavior, headline('goma:scaffold:oauth')
          Rails::Generators.invoke "goma:scaffold:oauth", [name_for_sub(:oauth), *args_for_sub], behavior: behavior
        end
      end

      def generate_mailers
        if (goma_config.modules & [:confirmable, :recoverable, :lockable]).present?
          log behavior, headline('goma:mailer')
          mailer_names.each do |mailer_name|
            Rails::Generators.invoke "goma:mailer", [mailer_name, *args_for_sub], behavior: behavior
          end
        end
      end

    private
      # Currently, javascript generator for goma is not implemented yet.
      # Therefore, I set "--no-javascripts".
      def args_for_sub
        @_initializer[1] + ["--resource-name=#{name}", "--no-javascripts"]
      end

      def name_for_sub(controller_type)
        return name.camelize if controller_type == :user

        controller_type = :authentication if controller_type == :oauth

        if options[:include_scope_name_into_controller_name]
          name.camelize + controller_type.to_s.camelize
        else
          controller_type.to_s.camelize
        end
      end

      def mailer_names
        @mailer_names ||= begin
          names = []
          if goma_config.modules.include? :confirmable
            names << (goma_config.activation_mailer_name || goma_config.default_mailer_name)
            if goma_config.email_confirmation_enabled
              names << (goma_config.email_confirmation_mailer_name || goma_config.default_mailer_name)
            end
          end
          if goma_config.modules.include? :lockable
            names << (goma_config.unlock_token_mailer_name || goma_config.default_mailer_name)
          end
          if goma_config.modules.include? :recoverable
            names << (goma_config.reset_password_mailer_name || goma_config.default_mailer_name)
          end
          names.uniq!
        end
      end

      def goma_config
        goma_config = Goma.config_for[name.underscore.to_sym] || Goma.config
      end

      def headline(str, length=64)
        str = " #{str} "
        ('=' * length).sub(/(={#{(length - str.length) / 2}})={#{str.length}}/) { $1 + str }
      end
    end
  end
end
