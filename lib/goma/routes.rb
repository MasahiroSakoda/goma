module Goma
  module Routes
    Goma.config.scopes.each do |scope|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{scope}_logged_in?
        lambda{ |r| !!r.env['warden'].authenticate(scope: :#{scope}) }
      end
      alias #{scope}_logged_in #{scope}_logged_in?

      def current_#{scope}(&block)
        if block
          if block.arity == 1
            lambda{ |r| yield r.env['warden'].authenticate(scope: :#{scope}) }
          else
            lambda{ |r| (u = r.env['warden'].authenticate(scope: :#{scope})) && u.instance_eval(&block) }
          end
        else
          lambda{ |r| r.env['warden'].authenticate(scope: :#{scope}) }
        end
      end
      RUBY
    end
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
    alias logged_in? #{Goma.config.default_scope}_logged_in?
    RUBY
  end
end
ActionDispatch::Routing::Mapper.send(:include, Goma::Routes)
