require 'rails/generators/active_record/model/model_generator'

module Goma
  module Generators
    module Model
      class ActiveRecordGenerator < ::ActiveRecord::Generators::ModelGenerator
        hide!
        source_root File.expand_path('../templates', __FILE__)

        def initialize(*)
          super
          merge_goma_user_attributes!
        end

        def add_options_to_migration
          return unless options['migration']
          if path = self.class.migration_exists?('db/migrate', migration_file_name)
            gsub_file(path,
                      "t.integer :#{goma_config.failed_attempts_attribute_name}",
                      "t.integer :#{goma_config.failed_attempts_attribute_name}, default: 0, null: false")
            gsub_file(path,
                      "t.integer :#{goma_config.login_count_attribute_name}",
                      "t.integer :#{goma_config.login_count_attribute_name}, default: 0, null: false")
          end
        end

      private
        def merge_goma_user_attributes!
          self.attributes = (goma_user_attributes.map do |attr|
            Rails::Generators::GeneratedAttribute.parse(attr)
          end + attributes).uniq{ |e| e.name }
        end

        def goma_scope
          (Goma.config.scopes & [name.underscore.to_sym]).first || Goma.config.default_scope
        end

        def goma_config
          @goma_config ||= {}
          @goma_config[name] ||= Goma.config_for[goma_scope] || Goma.config
        end

        def goma_user_attributes
          attrs = []
          if goma_config.modules.include? :password_authenticatable
            attrs << {type: :dummy,    field: :password_authenticatable}
            attrs << goma_config.authentication_keys.map{ |e| {field: e, type: :string, index: :uniq} }
            attrs << {type: :string,   field: goma_config.email_attribute_name,                 index: :uniq}
            attrs << {type: :string,   field: goma_config.encrypted_password_attribute_name}
          end

          if goma_config.modules.include? :confirmable
            attrs << {type: :dummy,    field: :confirmable}
            attrs << {type: :string,   field: goma_config.unconfirmed_email_attribute_name}
            attrs << {type: :string,   field: goma_config.confirmation_token_attribute_name,    index: :uniq}
            attrs << {type: :datetime, field: goma_config.confirmation_token_sent_at_attribute_name}
            attrs << {type: :string,   field: goma_config.activated_at_attribute_name}
            attrs << {type: :string,   field: goma_config.email_confirmed_at_attribute_name}
          end

          if goma_config.modules.include? :rememberable
            attrs << {type: :dummy,    field: :rememberable}
            attrs << {type: :string,   field: goma_config.remember_token_attribute_name,        index: :uniq}
            attrs << {type: :datetime, field: goma_config.remember_created_at_attribute_name}
          end

          if goma_config.modules.include? :lockable
            attrs << {type: :dummy,    field: :lockable}
            attrs << {type: :integer,  field: goma_config.failed_attempts_attribute_name}
            attrs << {type: :datetime, field: goma_config.locked_at_attribute_name}
            attrs << {type: :string,   field: goma_config.unlock_token_attribute_name,          index: :uniq}
            attrs << {type: :datetime, field: goma_config.unlock_token_sent_at_attribute_name}
          end

          if goma_config.modules.include? :recoverable
            attrs << {type: :dummy,    field: :recoverable}
            attrs << {type: :string,   field: goma_config.reset_password_token_attribute_name,  index: :uniq}
            attrs << {type: :datetime, field: goma_config.reset_password_token_sent_at_attribute_name}
          end

          if goma_config.modules.include? :trackable
            attrs << {type: :dummy,    field: :trackable}
            attrs << {type: :integer,  field: goma_config.login_count_attribute_name}
            attrs << {type: :datetime, field: goma_config.current_login_at_attribute_name}
            attrs << {type: :datetime, field: goma_config.last_login_at_attribute_name}
            attrs << {type: :string,   field: goma_config.current_login_ip_attribute_name}
            attrs << {type: :string,   field: goma_config.last_login_ip_attribute_name}
          end

          attrs.flatten.keep_if{|a| a[:field].present? }.uniq{|a| a[:field]}.
            map{ |a| "#{a[:field]}:#{a[:type]}#{a[:index] ? ":#{a[:index]}" : ''}" }
        end
      end
    end
  end
end
