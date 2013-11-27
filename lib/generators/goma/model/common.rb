module Goma
  module Generators
    module Model
      module Common
        def field_data
          auth_fields = (config.authentication_keys - [config.email_attribute_name]).map{ |key|
            uncomment_if('pass') + define_field_name(:string, key)
          }.join("\n")
<<RUBY
## Password authenticatable
#{auth_fields}
#{uncomment_if 'pass'}#{define_field :string,   :email_attribute_name}
#{uncomment_if 'pass'}#{define_field :string,   :encrypted_password_attribute_name}

## Confirmable
#{uncomment_if 'conf'}#{define_field :string,   :unconfirmed_email_attribute_name}
#{uncomment_if 'conf'}#{define_field :string,   :confirmation_token_attribute_name}
#{uncomment_if 'conf'}#{define_field :datetime, :confirmation_token_sent_at_attribute_name}
#{uncomment_if 'conf'}#{define_field :datetime, :activated_at_attribute_name}
#{uncomment_if 'conf'}#{define_field :datetime, :email_confirmed_at_attribute_name}

## Rememberable
#{uncomment_if 'reco'}#{define_field :datetime, :remember_created_at_attribute_name}

## Lockable
#{uncomment_if 'lock'}#{define_field :integer,  :failed_attempts_attribute_name, {default: 0, null: false} }
#{uncomment_if 'lock'}#{define_field :datetime, :locked_at_attribute_name}
#{uncomment_if 'lock'}#{define_field :string,   :unlock_token_attribute_name}
#{uncomment_if 'lock'}#{define_field :datetime, :unlock_token_sent_at_attribute_name}

## Recoverable
#{uncomment_if 'reco'}#{define_field :string,   :reset_password_token_attribute_name}
#{uncomment_if 'reco'}#{define_field :datetime, :reset_password_token_sent_at_attribute_name}

## Trackable
#{uncomment_if 'trac'}#{define_field :integer,  :login_count_attribute_name, {default: 0, null: false} }
#{uncomment_if 'trac'}#{define_field :datetime, :current_login_at_attribute_name}
#{uncomment_if 'trac'}#{define_field :datetime, :last_login_at_attribute_name}
#{uncomment_if 'trac'}#{define_field :string,   :current_login_ip_attribute_name}
#{uncomment_if 'trac'}#{define_field :string,   :last_login_ip_attribute_name}
RUBY
        end

        def index_data
          auth_keys = :password_authenticatable.in?(config.modules) ? config.authentication_keys : []

          tokens = []
          tokens << config.confirmation_token_attribute_name   if :confirmable.in? config.modules
          tokens << config.unlock_token_attribute_name         if :lockable.in?    config.modules
          tokens << config.reset_password_token_attribute_name if :recoverable.in? config.modules
          tokens << config.confirmation_token_attribute_name   if :confirmable.in? config.modules
          tokens.uniq!

          (auth_keys + tokens).map{ |key| add_unique key }.join("\n")
        end

        def scope
          name.underscore.to_sym
        end
      end
    end
  end
end
