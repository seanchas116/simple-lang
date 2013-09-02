
module SimpleLang

  class Procedure < Struct.new(:expressions)

    def eval(context)

      result = nil

      puts "evaluating a Procedure"

      expressions.each do |exp|
        result = exp.eval(context)
        p result
      end

      puts "evaluating ends"

      result

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

  class FunctionCall < Struct.new(:function, :parameters)

    def eval(context)
      if context.has_key?(function)
        values = parameters.map { |e| e.eval(context) }
        context[function].call(*values)
      else
        puts "function not found: #{function}"
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

  class CaseWhenExpression < Struct.new(:case_parameter, :when_statements, :else_procedure)

    def eval(context)

      case_value = case_parameter.eval(context)

      when_statements.each do |statement|
        if case_value == statement.parameter.eval(context)
          return statement.procedure.eval(context)
        end
      end

      if else_procedure
        return else_procedure.eval(context)
      end

      return nil

    end

  end

  class Function

    def initialize(parameters, procedure, context)
      @parameters = parameters
      @procedure = procedure
      @context = context
    end

    def call(*parameters)

      if parameters.length != @parameters.length
        puts "wrong parameter count"
        return nil
      end

      context = Hash.new(@context)

      @parameters.each_with_index do |item, index|
        context[item] = parameters[index]
      end

      @procedure.eval(context)

    end

  end

  class FunctionLiteral < Struct.new(:parameters, :procedure)

    def eval(context)
      Function.new(parameters, procedure, context)
    end

  end

end
