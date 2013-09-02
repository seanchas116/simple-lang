$:.unshift File.dirname(__FILE__)

require 'simple-lang/engine'

str = <<EOS
a = 1 - 2 * 3
b = a * (1.5+6.2)
x0 = 5
x_1 = -6 + x0
print(x_1)

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

print(sum(10, 0))

count = 0

counter = () =>
  count = count + 1
end

print(counter())
print(counter())

EOS

str_closure = <<EOS

get_counter = () =>
  count = 0
  () =>
    count = count + 1
  end
end

counter = get_counter()

print(counter())
print(counter())

EOS

engine = SimpleLang::Engine.new

engine.exec str
engine.exec str_control
engine.exec str_func
engine.exec str_func_rec
engine.exec str_closure, print_parsetree: true, print_ast: true

