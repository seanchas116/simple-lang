require 'parslet'

class Parser < Parslet::Parser

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:lparen) { str('(') >> space? }
  rule(:rparen) { str(')') >> space? }
  rule(:comma) { str(',') >> space? }
  rule(:operator) { match['+-/*%^'] >> space? }

  rule(:funcall) { identifier.as(:identifier) >> lparen >> (expression.as(:expression) >> (comma >> expression.as(:expression)).repeat(0)).maybe >> rparen }
  rule(:number) { ( match('[0-9]').repeat(1) >> ( str('.') >> match('[0-9]').repeat(1) ).maybe ) >> space? }
  rule(:identifier) { match('[a-zA-Z]').repeat(1) >> space? }
  rule(:parenexpression) { lparen >> expression.as(:expression) >> rparen }
  rule(:value) { funcall.as(:funcall) | number.as(:number) | identifier.as(:identifier) | parenexpression }

  rule(:expression) { value >> (operator.as(:operator) >> value).repeat(0) }

  root :expression

end
