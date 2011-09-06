require 'ramaze'
require 'sequel'

require __DIR__('config/config')
require __DIR__('config/database')

Dir.glob(__DIR__('controller/**/*.rb')).each do |controller|
  require(controller)
end

Dir.glob(__DIR__('model/**/*.rb')).each do |model|
  require(model)
end
