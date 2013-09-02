
class Procedure

  attr_accessor :expressions, :context

  def initialize(expressions)
    @expressions = expressions
    @context = Hash[]
  end

  def eval()
    @expressions.each do |exp|
      p exp.eval(@context)
    end
  end

end


class Variable < Struct.new(:name)

  def set(context, value)
    context[name] = value
    self
  end

  def eval(context)
    if context.has_key?(name)
      context[name]
    else
      puts "variable not found: #{name}"
      nil
    end
  end

end

class NumberLiteral < Struct.new(:value)

  def eval(context)
    value
  end

end

class FunCall < Struct.new(:fun, :parameters)

  def eval(context)
    if context.has_key?(fun)
      values = parameters.map { |e| e.eval(context) }
      context[fun].call(*values)
    else
      puts "function not found: #{fun}"
      nil
    end
  end

end

class UnaryOperation < Struct.new(:op, :right)

  def eval(context)
    case op
    when '+'
      right.eval(context)
    when '-'
      -right.eval(context)
    when '!'
      !right.eval(context)
    end
  end

end

class BinaryOperation < Struct.new(:left, :op, :right)

  def eval(context)
    case op
    when '='
      left.set(context, right.eval(context)).eval(context)
    when '=='
      left.eval(context) == right.eval(context)
    when '!='
      left.eval(context) != right.eval(context)
    when '<'
      left.eval(context) < right.eval(context)
    when '<='
      left.eval(context) <= right.eval(context)
    when '>'
      left.eval(context) > right.eval(context)
    when '>='
      left.eval(context) >= right.eval(context)
    when '+'
      left.eval(context) + right.eval(context)
    when '-'
      left.eval(context) - right.eval(context)
    when '*'
      left.eval(context) * right.eval(context)
    when '/'
      left.eval(context) / right.eval(context)
    when '%'
      left.eval(context) % right.eval(context)
    when '^'
      left.eval(context) ^ right.eval(context)
    end
  end

end
