require 'pp'
require './parser.rb'

def parse(str)
  parsed = Parser.new.parse(str)
  pp parsed
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

str = <<EOS
a = 2 * 3
b = 3
x0 = 5
x_1 = -6

c = 4

EOS

print str

parse(str)
