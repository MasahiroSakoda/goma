$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "goma/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "goma"
  s.version       = Goma::VERSION
  s.authors       = ["Kentaro Imai"]
  s.email         = ["kentaroi@gmail.com"]
  s.homepage      = "https://github.com/kentaroi/goma"
  s.summary       = "An authentication solution for Rails 4"
  s.description   = "An authentication solution for Rails 4"
  s.licenses      = ["MIT"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']
  s.post_install_message =<<-MESSAGE

\e[32mThank you for installing!

You can use this gem as follows:

\e[0mrails g goma:install\e[32m

Edit config/initializers/goma.rb to fit your needs.

\e[0mrails g goma:scaffold User\e[32m


===========================================================================
Some setup you must do manually if you heven't yet:

- Ensure you have defined default url options in your environments files.
  Here is an example of default_url_options appropriate for a development
  environment in config/environments/development.rb

  \e[0mconfig.action_mailer.default_url_options = { host: 'localhost:3000' }\e[32m

  in production, :host should be set to the actual host of your application.

===========================================================================


That's it.

This gem is in early development phase and I do not recommend you to use this for production for a while.
Bug reports and pull requests are welcome.

I am surprised that this gem has been downloaded over 200 times, in spite of pre release versions of v0.0.1.
And, I feel bad about there were lots of bugs and incomplete implementations in previous versions.

I will release this as a release candidate, but will add lots of code before v0.0.1.

Enjoy!\e[0m
MESSAGE

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "warden"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bcrypt", "~> 3.0"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "timecop"
  s.add_development_dependency "capybara"
  s.add_development_dependency "minitest-ansi"
  s.add_development_dependency "single_test"
  s.add_development_dependency "byebug"
end
