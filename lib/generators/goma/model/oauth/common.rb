module Goma
  module Generators
    module Model
      module OAuth
        module Common
          def field_data
<<RUBY
#{define_field :string, :oauth_provider_attribute_name}
#{define_field :string, :oauth_uid_attribute_name}
RUBY
          end

          def index_data
            ["#{scope}_id", [config.oauth_provider_attribute_name, config.oauth_uid_attribute_name]].
              map{ |content| add_index(content) }.join("\n")
          end

          def scope
            Goma.config.scopes.find do |scope|
              config = Goma.config_for[scope]
              config && config.oauth_authentication_class_name.tableize == table_name
            end || Goma.config.default_scope
          end
        end
      end
    end
  end
end
