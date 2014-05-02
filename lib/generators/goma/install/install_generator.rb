require 'rails/generators/base'
module Goma
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc <<DESC
Description:
    Copies Goma configuration file to your application's initializer directory.
DESC

      def copy_config_file
        template 'goma.rb', 'config/initializers/goma.rb'
      end
    end
  end
end
