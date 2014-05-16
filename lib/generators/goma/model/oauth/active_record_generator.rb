require 'rails/generators/active_record/model/model_generator'

module Goma
  module Generators
    module Model
      module OAuth
        class ActiveRecordGenerator < ::ActiveRecord::Generators::ModelGenerator
          @namespace      = 'goma:model:oauth:active_record'
          @generator_name = 'active_record'
          hide!

          source_root File.expand_path('../templates', __FILE__)

          def initialize(*)
            super
            merge_goma_oauth_attributes!
          end

          # This method overwrite is needed, because template source location is different. (one level deeper)
          # I know this is terrible hack.
          def create_migration_file
            return unless options[:migration] && options[:parent].nil?
            attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
            migration_template "../../../migration/templates/create_table_migration.rb", "db/migrate/create_#{table_name}.rb"
          end

          def inject_index
            return unless options['migration']
            if path = self.class.migration_exists?('db/migrate', migration_file_name)
              insert_into_file(path, goma_oauth_index, {after: /^\s{4,}end\s*\n/})
            end
          end

        private
          def merge_goma_oauth_attributes!
            self.attributes = (goma_oauth_attributes.map do |attr|
              Rails::Generators::GeneratedAttribute.parse(attr)
            end + attributes).uniq{ |e| e.name }
          end

          def goma_scope
            Goma.config.scopes.find do |scope|
              config = Goma.config_for[scope]
              config && config.oauth_authentication_class_name.tableize == table_name
            end || Goma.config.default_scope
          end

          def goma_config
            @goma_config ||= {}
            @goma_config[name] ||= Goma.config_for[goma_scope] || Goma.config
          end

          def goma_oauth_attributes
            attrs = []
            attrs << {type: :string, field: goma_config.oauth_provider_attribute_name}
            attrs << {type: :string, field: goma_config.oauth_uid_attribute_name}
            attrs << {type: :belongs_to, field: goma_scope}

            attrs.map{ |a| "#{a[:field]}:#{a[:type]}#{a[:index] ? ":#{a[:index]}" : ''}" }
          end

          def goma_oauth_index
            "    add_index :#{name.tableize}, [:#{goma_config.oauth_provider_attribute_name}, :#{goma_config.oauth_uid_attribute_name}], unique: :true\n"
          end
        end
      end
    end
  end
end
