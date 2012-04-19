Pry.config.prompt = [
  # Regular prompt.
  proc do |obj, nest_level|
    "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} (" \
      + Pry::Helpers::Text.green(Pry.view_clip(obj)) \
      + ')> '
  end,
  # Wait prompt
  proc do |obj, nest_level|
    "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} (" \
      + Pry::Helpers::Text.green(Pry.view_clip(obj)) \
      + ')* '
  end
]

# vim: set ft=ruby:
