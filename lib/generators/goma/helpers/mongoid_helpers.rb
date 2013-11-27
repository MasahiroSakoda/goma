module Goma
  module Generators
    module Helpers
      module MongoidHelpers
      private
        def generate_model
          invoke 'mongoid:model', [name] unless model_exists? && behavior == :invoke
        end

        def inject_goma_content
          class_path = if namespaced?
                         class_name.to_s.split("::")
                       else
                         [class_name]
                       end

          indent_depth = class_path.size

          content = indent(indent_depth, mongoid_contents)
          inject_into_file model_path, content, after: "include Mongoid::Document\n" if model_exists?
        end

        def field_to_s(type, field_name, options)
          "field #{field_name_type_and_options(field_name, type, options)}"
        end

        def field_name_type_and_options(field_name, type, options)
          buffer = ":#{field_name},".ljust(30) + "type: #{class_type_from_db_type(type)}"
          buffer += ', ' + options_to_s(options) if options
          buffer
        end

        def class_type_from_db_type(type)
          types ||= {string: String, text: String, integer: Integer, float: Float, decimal: BigDecimal,
                     datetime: Time, timestamp: Time, time: Time, date: Time, binary: BSON::Binary,
                     boolean: Boolean, hstore: Hash, array: Array}
          types[type]
        end

        def options_to_s(options)
          "default: #{options[:default]}"
        end

        def add_unique(field_name)
          "index {#{field_name}: 1}, {unique: true}"
        end

        def add_index(field_name_or_names)
          key = '{' + Array(field_name_or_names).map{ |e| "#{e}: 1" }.join(', ') + '}'

          "index #{key}"
        end
      end
    end
  end
end
