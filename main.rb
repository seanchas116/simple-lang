$:.unshift File.dirname(__FILE__)

require 'pp'
require 'simple-lang/parser'
require 'simple-lang/ast'
require 'simple-lang/transform'

include SimpleLang

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

  proceduce.eval(context)

end

str = <<EOS
a = 1 - 2 * 3
b = a * (1.5+6.2)
c = floor(b)
x0 = 5
x_1 = -6 + x0
x2 = 2 * (hypot(x0, x_1) + 2)
EOS

str_control = <<EOS

x = 0

case 2
when 5
  1
when 2
  1 + 3
end

case x
when 1
else
  2
end
EOS

str_func = <<EOS

f = (a, b) =>
  a = a + 2
  a + b
end

f(1, 2)

EOS

str_func_rec = <<EOS

y = 10

sum = (x, memo) =>
  case x
  when 0
    memo
  else
    sum(x-1, memo + x)
  end
end

sum(5, 0)

EOS

eval(parse(str))
eval(parse(str_control))
eval parse(str_func)
eval parse(str_func_rec)
