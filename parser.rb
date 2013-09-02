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
  rule(:unaryop) { any_str(UNARY_OPERATORS).as(:op) >> space? }
  
  rule(:parameters) do
    lparen >> ( expression >> ( comma >> expression.repeat(0) ).maybe >> rparen ).as(:parameters)
  end

  rule(:funcall) { (identifier >> parameters).as(:funcall) }

  rule(:number) do
    ( match['0-9'].repeat(1) >> ( str('.') >> match['0-9'].repeat(1) ).maybe ).as(:number) >> space?
  end

  rule(:identifier) do
    ( match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat(0) ).as(:identifier) >> space?
  end

  rule(:paren_expression) { lparen >> expression >> rparen }
  
  rule(:value) { (funcall | number | identifier | paren_expression).as(:value) }

  rule(:unary_expression) { (unaryop.maybe >> value).as(:unary_expression) }
  rule(:sub_expr_0) { unary_expression }

  BINARY_OPERATORS_WITH_PRECEDENCE.each_with_index do |operators, index|
    rule("sub_expr_#{index+1}") do
      prev = method("sub_expr_#{index}").call
      (prev.as(:left) >> (any_str(operators).as(:op) >> space? >> prev.as(:right)).repeat(1)).as(:binary_expression) | prev
    end
  end

  rule(:expression) { method("sub_expr_#{BINARY_OPERATORS_WITH_PRECEDENCE.length}").call }

  rule(:procedure) { ((expression.maybe >> linebreak).repeat(0) >> expression.maybe).as(:procedure) }

  root :procedure

end
