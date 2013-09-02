$:.unshift File.dirname(__FILE__)

require 'pp'
require 'simple-lang/parser'
require 'simple-lang/ast'
require 'simple-lang/transform'

def parse(str)
  parsed = Parser.new.parse(str)
  pp parsed
  proceduce = Transform.new.apply(parsed)
  pp proceduce

  return proceduce

rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

def eval(proceduce)

  context = Hash[]
  context["floor"] = proc { |x| x.floor }
  context["hypot"] = Math.method(:hypot)

  proceduce.context = context
  proceduce.eval

end

str = <<EOS
a = 1 - 2 * 3
b = a * (1.5+6.2)
c = floor(b)
x0 = 5
x_1 = -6 + x0
x2 = 2 * (hypot(x0, x_1) + 2)
EOS

str2 = "
a > 1
a > 1
a == 2
3 + (3 + 2) * f(2, 3) + f(1)
"

eval(parse(str))
