# Goma 胡麻

An authentication solution for Rails 4.
Currently supports ActiveRecord only.

The API is almost same as [Sorcery](https://github.com/NoamB/sorcery) \[[LICENSE](https://raw.githubusercontent.com/NoamB/sorcery/master/LICENSE.txt)\].
Lots of code are borrowed or shamelessly copied from \[[Devise](https://github.com/plataformatec/devise) [LICENSE](https://raw.githubusercontent.com/plataformatec/devise/master/MIT-LICENSE)\].

Thank maintainers, committers and contributers to above two gems.

Currently, Goma is under development.
Because I am not good at English, writing documents, corrections, and suggesting better module, class, variable or method names are welcome.

Goma is an authentication solution for Rails 4 based on Warden. It:

- allows you to use almost same as Sorcery
- supports authentication in routes
- allows you to have multiple models signed in at the same time

It is composed of following modules:

- Password authenticatable
- Omniauthable
- Confirmable
- Recoverable
- Rememberable
- Trackable
- Timeoutable
- Validatable
- Lockable


## Getting started
Goma works with Rails 4. You can add it to your Gemfile with:

```ruby
gem 'goma'
```

Run the bundle command to install it.
After you install Goma and add it to your Gemfile, you need to run the generator:

```console
rails generate goma:install
```

The generator will install an initializer which describes ALL Goma's configuration options and you MUST take a look at it and change options to fit your needs. When you are done, you are ready to add Goma model to any of your models using the generator.

```
rails generate goma:model MODEL
```

Replace MODEL by the class name used for the applications users, it's frequently `user` but could also be anything you want. This will create a model (if one does not exist) with a migration (which is configured based on the initializer file which is created by `rails generate goma:install`).


## API summary

```
  require_login # this is a before filter (default scope)
  require_user_login # ditto. You can specify a scope.
  login(identifier, password, remember_me=false) # You can use multiple identifiers such as username and email
  force_login(user) # Login without credentials (same as auto_login in Sorcery gem)
  logout(scope=Goma.config.default_scope) # Logout. you can specify a scope.
  user_logout # ditto
  logged_in? # Available in view
  user_logged_in? # ditto. You can specify a scope.
  current_user # Available in view. If you have an :admin scope, you can use current_admin

  remember_me!
  forget_me!

  # Confirmable
  User.load_from_activation_token(token)
  User#activate!
  User.load_from_email_confirmation_token(token)
  User#confirm_email!

  # Recoverable
  User.load_from_reset_password_token(token)
  User#send_reset_password_instructions!
  User#change_password!(new_password, new_password_confirmation)

  # Lockable
  User.load_from_unlock_token(token)
  User#lock_access!
  User#unlock_access!
  User#access_locked?
  User#last_attempt?

  # Omniauthable
  User.create_with_omniauth!(omniauth)
  User#fill_with_omniauth # This method is called when creating user object with OmniAuth
  Authentication#fill_with_omniauth # This method is called when creating authentication object with OmniAuth
```
