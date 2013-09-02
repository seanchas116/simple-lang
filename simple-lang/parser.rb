require 'parslet'

module SimpleLang

  UNARY_OPERATORS = %w(! + -)

  BINARY_OPERATORS_WITH_PRECEDENCE = [
    %w(^),
    %w(* / %),
    %w(+ -),
    %w(=),
    %w(== != <= < >= >),
    %w(&& ||)
  ]

  RESERVED_WORDS = %w(case when else end)

  class Parser < Parslet::Parser

    def any_str(strings)
      strings.map {|x| str(x)}.inject {|result, x| result | x}
    end

    # characters

    rule(:space) { match['[:blank:]'].repeat(1) }
    rule(:space?) { space.maybe }
    rule(:linebreak) { match['\\n'] >> space? }

    rule(:lparen) { str('(') >> space? }
    rule(:rparen) { str(')') >> space? }
    rule(:comma) { str(',') >> space? }

    rule(:word) do
      RESERVED_WORDS.map {|x| str(x).absent?}.inject {|memo, x| memo >> x} >> match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat(0)
    end
    
    # values
    
    rule(:parameters) do
      lparen >> ( expression >> ( comma >> expression.repeat(0) ).maybe >> rparen ).as(:parameters)
    end

    rule(:funcall) { (identifier >> parameters).as(:funcall) }

    rule(:number) do
      ( match['0-9'].repeat(1) >> ( str('.') >> match['0-9'].repeat(1) ).maybe ).as(:number) >> space?
    end

    rule(:identifier) { word.as(:identifier) >> space? }

    rule(:paren_expression) { lparen >> expression >> rparen }

    rule(:value) { (control_expression | funcall | number | identifier | paren_expression).as(:value) }

    # unary expressions

    rule(:unaryop) { any_str(UNARY_OPERATORS).as(:op) >> space? }
    rule(:unary_expression) { (unaryop.maybe >> value).as(:unary_expression) }

    # binary expressions

    rule(:binary_subexpr_0) { unary_expression }

    BINARY_OPERATORS_WITH_PRECEDENCE.each_with_index do |operators, index|
      rule("binary_subexpr_#{index+1}") do
        prev = method("binary_subexpr_#{index}").call
        (prev.as(:left) >> (any_str(operators).as(:op) >> space? >> prev.as(:right)).repeat(1)).as(:binary_expression) | prev
      end
    end

    # procedures

    rule(:expression) { method("binary_subexpr_#{BINARY_OPERATORS_WITH_PRECEDENCE.length}").call }

    rule(:procedure) { ((expression.maybe >> linebreak).repeat(0)).as(:procedure) }
    rule(:procedure_top) { ((expression.maybe >> linebreak).repeat(0) >> expression.repeat(0,1)).as(:procedure) }

    # controls

    rule(:end_statement) { (str('end') >> space?).as(:end_statement) }
    rule(:case_statement) { (str('case') >> space? >> expression.as(:parameter) >> linebreak).as(:case_statement) }
    rule(:when_statement) { (str('when') >> space? >> expression.as(:parameter) >> linebreak >> procedure.as(:content)).as(:when_statement) }
    rule(:else_statement) { (str('else') >> space? >> linebreak >> procedure.as(:content)).as(:else_statement) }

    rule(:case_when_expression) do
      (case_statement >> when_statement.repeat(0).as(:whens) >> else_statement.repeat(0, 1).as(:elses) >> end_statement).as(:case_when_expression)
    end

    rule(:control_expression) { case_when_expression }

    root :procedure_top

  end

end
