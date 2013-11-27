module Goma
  module Generators
    module Helpers
      module ActiveRecordHelpers
      private
        def copy_goma_migration
          if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?)
            migration_template 'migration_existing.rb', "db/migrate/#{adding_migration_name}.rb"
          else
            migration_template 'migration.rb', "db/migrate/goma_create_#{table_name}.rb"
          end
        end

        def generate_model
          invoke 'active_record:model', [name], migration: false unless model_exists? && behavior == :invoke
        end

        def field_to_s(type, field_name, options)
          "t.#{type.to_s.ljust(10)} #{column_name_and_options(field_name, options)}"
        end

        def column_name_and_options(column_name, options)
          if options
            ":#{column_name},".ljust(30) + options_to_s(options)
          else
            ":#{column_name}"
          end
        end

        def options_to_s(options)
          options.map{|k,v| "#{k}: #{v}"}.join(', ')
        end

        def add_unique(column_name)
          "add_index :#{table_name}, #{column_name_and_options(column_name, {unique: true})}"
        end

        def add_index(column_name_or_names)
          key = case column_name_or_names
                when Array
                  '[' + column_name_or_names.map{ |e| ":#{e}" }.join(', ') + ']'
                else
                  ":#{column_name_or_names}"
                end

          "add_index :#{table_name}, #{key}"
        end
      end
    end
  end
end
