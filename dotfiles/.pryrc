require 'pry-theme'
require 'pry-doc'

Pry.config.theme = 'paper'

Pry.config.theme_options = { paint_key_as_symbol: true }

Pry.config.prompt = Pry::Prompt.new(
  'custom',
  'Custom Pry prompt',
  [
  # Regular prompt.
  proc do |obj, nest_level, _|
    "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} > "
  end,
  # Wait prompt
  proc do |obj, nest_level, _|
    "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} * "
  end
  ]
)
