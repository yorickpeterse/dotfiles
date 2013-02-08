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

# Commands

Pry.commands.block_command 'lookup-method',
'Looks up a method using ObjectSpace' do |name|
  name    = name.to_sym
  results = []

  ObjectSpace.each_object(Module) do |obj|
    if obj.respond_to?(:instance_methods) and obj.instance_methods.include?(name)
      results << "#{obj}##{name}"
    end

    if obj.respond_to?(:class_methods) and obj.class_methods.include?(name)
      results < "#{obj}.#{name}"
    end
  end

  puts results.sort.join("\n")
end

# vim: set ft=ruby:
