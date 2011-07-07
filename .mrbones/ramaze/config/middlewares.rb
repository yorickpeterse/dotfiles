# All Rack middlewares should go in a block like the one below. Different combinations
# can be used for different versions by setting the first argument of the middleware!
# method to a symbol containing the name of the environment (e.g. :live).
#
# For development purposes we'll be loading various middlewares to make it easier to
# detect errors, reloading the code and so on.
Ramaze.middleware! :dev do |m|
  # Rack::Lint is used to validate all code according to the Rack specification.
  # It's not recommended to use this middleware in a production environment as it will
  # slow your application down a bit.
  m.use Rack::Lint

  # Shows an error page whenever an exception was raised. It's not recommended to use
  # this middleware on a production server as it may reveal sensitive details to the
  # visitor.
  m.use Rack::ShowExceptions

  # Pretty much the same as Rack::ShowExceptions.
  m.use Rack::ShowStatus
  
  # Routes exceptions to different actions, can be useful for catching 404's and such.
  # m.use Rack::RouteExceptions
  
  # Automatically reloads your application whenever it detects changes. Note that this
  # middleware isn't always as accurate so there may be times when you have to manually
  # restart your server.
  m.use Ramaze::Reloader
  
  # Runs Ramaze based on all mappings and such.
  m.run Ramaze::AppMap
end
