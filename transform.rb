require 'parslet'
require './ast.rb'

class Transform < Parslet::Transform

  rule(:number => simple(:x)) { NumberLiteral.new(x.to_s.strip.to_f) }
  rule(:identifier => simple(:name)) { Variable.new(name.to_s.strip) }
  rule(:unaryop => simple(:op), :value => simple(:value)) do
    if op
      UnaryOperation.new(op.to_s.strip, value)
    else
      value
    end
  end

  LeftItem = Struct.new(:left)
  RightItem = Struct.new(:op, :right)
  ExpressionsItem = Struct.new(:expressions)

  rule(:left => simple(:x)) { LeftItem.new(x) }
  rule(:op => simple(:op), :right => simple(:right)) { RightItem.new(op, right) }

  rule(:funcall => simple(:funcall)) { funcall } 

  rule(:identifier => simple(:identifier), :parameters => simple(:parameterItem)) do
    if ExpressionsItem === parameterItem
      FunCall.new(identifier, parameterItem.expressions)
    else
      FunCall.new(identifier, [parameterItem])
    end
  end

  rule(sequence(:seq)) do

    if LeftItem === seq[0]
      left = seq[0].left
      seq[1..-1].each do |item|
        left = BinaryOperation.new(left, item.op.to_s.strip, item.right)
      end
      left
    else
      ExpressionsItem.new(seq)
    end

  end

  rule(:expression => simple(:x)) { x }

  rule(:procedure => simple(:item)) do
    if ExpressionsItem == item
      Procedure.new(item.expressions)
    else
      Procedure.new([item])
    end
  end

end
