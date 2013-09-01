require 'parslet'

UNARY_OPERATORS = %w(+ -)

BINARY_OPERATORS_WITH_PRECEDENCE = [
  %w(^),
  %w(* / %),
  %w(+ -),
  %w(=),
  %w(== != <= < >= >),
  %w(&& ||)
]

class Parser < Parslet::Parser

  def any_str(strings)
    strings.map {|x| str(x)}.inject {|result, x| result | x}
  end

  rule(:space) { match['[:blank:]'].repeat(1) }
  rule(:space?) { space.maybe }
  rule(:linebreak) { match['\\n'] >> space? }

  rule(:lparen) { str('(') >> space? }
  rule(:rparen) { str(')') >> space? }
  rule(:comma) { str(',') >> space? }

  rule(:unaryop) { any_str(UNARY_OPERATORS) >> space? }
 
  rule(:funcall) { identifier.as(:identifier) >> (lparen >> (expression.as(:expression) >> (comma >> expression.as(:expression)).repeat(0)).maybe >> rparen).as(:parameters) }
  rule(:number) { ( match['0-9'].repeat(1) >> ( str('.') >> match['0-9'].repeat(1) ).maybe ) >> space? }
  rule(:identifier) { match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat(0) >> space? }
  rule(:parenexpression) { lparen >> expression.as(:expression) >> rparen }
  rule(:value) { funcall.as(:funcall) | number.as(:number) | identifier.as(:identifier) | parenexpression }

  rule(:unary_subexpr) { unaryop.maybe.as(:unaryop) >> value.as(:value) }

  rule(:sub_expr_0) { unary_subexpr }

  BINARY_OPERATORS_WITH_PRECEDENCE.each_with_index do |operators, index|
    rule("sub_expr_#{index+1}") do
      prev = method("sub_expr_#{index}").call
      prev.as(:left) >> ((any_str(operators) >> space?).as(:op) >> prev.as(:right)).repeat(1) | prev
    end
  end

  rule(:expression) { method("sub_expr_#{BINARY_OPERATORS_WITH_PRECEDENCE.length}").call }

  rule(:procedure) { ((expression.as(:expression).maybe >> linebreak).repeat(0) >> expression.as(:expression).maybe).as(:procedure) }

  root :procedure

end
