module Goma
  module Generators
    module Helpers
      module OrmHelpers
      private
        def model_contents
          "goma\n"
        end

        def model_exists?
          File.exists?(File.join(destination_root, model_path))
        end

        def migration_exists?
          Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_#{adding_migration_name}.rb$/).first
        end

        def migration_path
          @migration_path ||= 'db/migrate'
        end

        def model_path
          @model_path ||= "app/models/#{file_path}.rb"
        end

        def indent(level, content)
          spacer = '  ' * level
          content.split("\n").map{|line| line.length == 0 ? line : spacer + line}.join("\n") << "\n"
        end

        def uncomment_if(module_name)
          config.modules.find{|mod| mod =~ /^#{module_name}/ } ? '' : '# '
        end

        def define_field(type, field_key, options=nil)
          field_name = config.send(field_key)
          return "# config.#{field_key} is not defined." unless field_name

          define_field_name(type, field_name, options)
        end

        def define_field_name(type, field_name, options=nil)
          str = defined_field_names.include?(field_name) ?  '#dup# ' : ''
          defined_field_names.add(field_name)
          str << field_to_s(type, field_name, options)
          str
        end

        def defined_field_names
          @defined_field_names ||= Set.new
        end

        def config
          @config ||= Goma.config_for[scope] || Goma.config
        end
      end
    end
  end
end
