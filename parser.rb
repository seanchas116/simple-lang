require 'parslet'

class Parser < Parslet::Parser

  rule(:space) { match['[:blank:]'].repeat(1) }
  rule(:space?) { space.maybe }
  rule(:linebreak) { match['\\n'] >> space? }

  rule(:lparen) { str('(') >> space? }
  rule(:rparen) { str(')') >> space? }
  rule(:comma) { str(',') >> space? }
  rule(:binaryop) { match['+-/*%^='] >> space? }
  rule(:unaryop) { match['+-'] >> space? }

  rule(:funcall) { identifier.as(:identifier) >> lparen >> (expression.as(:expression) >> (comma >> expression.as(:expression)).repeat(0)).maybe >> rparen }
  rule(:number) { ( match['0-9'].repeat(1) >> ( str('.') >> match['0-9'].repeat(1) ).maybe ) >> space? }
  rule(:identifier) { match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat(0) >> space? }
  rule(:parenexpression) { lparen >> expression.as(:expression) >> rparen }
  rule(:value) { funcall.as(:funcall) | number.as(:number) | identifier.as(:identifier) | parenexpression }
  rule(:factor) { unaryop.maybe.as(:unaryop) >> value.as(:value) }

  rule(:expression) { factor.as(:factor) >> (binaryop.as(:binaryop) >> factor.as(:factor)).repeat(0) }
  rule(:program) { (expression.as(:expression).maybe >> linebreak).repeat(0) }

  root :program

end
