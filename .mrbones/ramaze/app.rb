require 'ramaze'
require 'ramaze/log/rotatinginformer'
require 'sequel'

# Configure our application
require __DIR__('config/config')

# Load our database settings
require __DIR__('config/database')

# Load all Rack middlewares
require __DIR__('config/middlewares')

# Load all controllers
Dir.glob(__DIR__('controller/**/*.rb').each do |controller|
  require(controller)
end

Dir.glob(__DIR__('model/**/*.rb')).each do |model|
  require(model)
end
