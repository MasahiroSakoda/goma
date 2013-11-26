module Goma
end

require 'rails'

require 'goma/hooks'

if defined? Rails
  require 'goma/railtie'
end
