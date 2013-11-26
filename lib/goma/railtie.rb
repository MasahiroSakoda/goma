module Goma
  class Railtie < ::Rails::Railtie
    initializer 'goma' do |_app|
      ActiveSupport.on_load(:active_record) do
        require 'goma/models'
        ::ActiveRecord::Base.send(:include, Goma::Models)
      end

      begin; require 'mongoid'; rescue LoadError; end
      if defined? ::Mongoid
      end
    end
  end
end
