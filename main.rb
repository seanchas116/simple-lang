require 'pp'
require './parser.rb'
require './ast.rb'
require './transform.rb'

def parse(str)
  parsed = Parser.new.parse(str)
  pp parsed
  transformed = Transform.new.apply(parsed)
  pp transformed

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

str2 = "
a > 1
a > 1
a == 2
3 + (3 + 2) * f(2, 3) + f(1)
"

print str

parse("a > 1")
parse("b * 2")
parse("a * b - c")
parse str2
