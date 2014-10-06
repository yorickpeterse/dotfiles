# Helper methods for configuring Pry.

def Pry._prompt_name
  return "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"
end

# Configuration

Pry.config.theme = 'autumn'

Pry.config.prompt = [
  # Regular prompt.
  proc do |obj, nest_level, _|
    "#{Pry._prompt_name} > "
  end,
  # Wait prompt
  proc do |obj, nest_level, _|
    "#{Pry._prompt_name} * "
  end
]

# vim: set ft=ruby:
