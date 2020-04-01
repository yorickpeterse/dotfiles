Pry.config.theme = 'happy_hacking'

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
