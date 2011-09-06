# Specify the root directory. This is required since there are multiple
# directories to load resources from. This directory will be used for the
# database logger, modes, etc.
Ramaze.options.roots.push(__DIR__('../'))

# Set the application's mode. Available modes are "dev" and "live"
Ramaze.options.mode     = :dev
Ramaze.options.app.name = :'ramaze'

# The session identifier to use for cookies.
Ramaze.options.session.key = 'ramaze.sid'

# Cache settings. These are turned off for the development server to make it
# easier to debug potential errors.
Ramaze::View.options.cache      = false
Ramaze::View.options.read_cache = false

