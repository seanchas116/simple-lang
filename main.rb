require 'pp'
require './parser.rb'
require './ast.rb'

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

c = f(x, y)

EOS

print str

parse(str)
