require 'bacon'
require 'stringio'
require File.expand_path('../bacon/color_output', __FILE__)

Bacon.extend(Bacon::ColorOutput)
Bacon.summary_on_exit

##
# Runs the block in a new thread and redirects $stdout and $stderr. The output
# normally stored in these variables is stored in an instance of StringIO which
# is returned as a hash.
#
# @example
#  out = catch_output do
#    puts 'hello'
#  end
#
#  puts out # => {:stdout => "hello\n", :stderr => ""}
#
# @author Yorick Peterse
# @return [Hash]
#
def catch_output
  data = {
    :stdout => nil,
    :stderr => nil
  }

  Thread.new do
    $stdout, $stderr = StringIO.new, StringIO.new

    yield

    $stdout.rewind
    $stderr.rewind

    data[:stdout], data[:stderr] = $stdout.read, $stderr.read

    $stdout, $stderr = STDOUT, STDERR
  end.join

  return data
end

##
# Allows developers to create stubbed objects similar to Mocha's stub() method.
#
# @example
#  obj = stub(:language => 'Ruby')
#  puts obj.language # => "Ruby"
#
# @author Yorick Peterse
# @param  [Hash] attributes A hash containing all the attributes to set and
#  their values.
# @return [Class]
#
def stub(attributes)
  obj = Struct.new(*attributes.keys).new

  attributes.each do |k, v|
    obj.send("#{k}=", v)
  end

  return obj
end
