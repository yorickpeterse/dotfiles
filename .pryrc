Pry.config.theme = 'autumn'

Pry.config.prompt = [
  # Regular prompt.
  proc do |obj, nest_level, _|
    "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} (#{Pry.view_clip(obj)})> "
  end,
  # Wait prompt
  proc do |obj, nest_level, _|
    "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} (#{Pry.view_clip(obj)})* "
  end
]

Pry.commands.block_command 'lookup-method',
'Looks up a method using ObjectSpace' do |name|
  name = name.to_sym

  ObjectSpace.each_object(Module) do |obj|
    if obj.respond_to?(:instance_methods) and obj.instance_methods.include?(name)
      puts "#{obj}##{name}"
    end

    if obj.respond_to?(:class_methods) and obj.class_methods.include?(name)
      puts "#{obj}.#{name}"
    end
  end
end

# vim: set ft=ruby:
