require 'simple-lang/error'
require 'simple-lang/context'

module SimpleLang

  module Result

    def flat_map(&f)
      f.(get)
    end

    def map(&f)
      LiteralResult.new(f.(get))
    end

  end

  class LiteralResult

    include Result
    attr_reader :value

    def initialize(value)
      if Result === value
        raise "nested Result"
      end
      @value = value
    end

    def get
      value
    end

    def set(x)
      raise ExecError.new("cannot set value to literal")
    end

  end

  class VariableResult < Struct.new(:context, :name)

    include Result

    def get
      unless context.has_key?(name)
        raise ExecError.new("variable not found: #{name}")
      end
      context[name]
    end

    def set(x)
      context[name] = x
    end

  end

  class MemberResult < Struct.new(:variable_result, :name)

    include Result

    def get
      variable_result.get[name]
    end

    def set(x)
      variable_result.get[name] = x
    end

  end

  class ProcedureAST < Struct.new(:expressions)

    def eval(context)
      result = nil
      expressions.each do |exp|
        result = exp.eval(context).get
      end
      LiteralResult.new(result)
    end

  end

  class VariableAST < Struct.new(:name)

    def eval(context)
      VariableResult.new(context, name)
    end

  end

  class NumberAST < Struct.new(:value)

    def eval(context)
      LiteralResult.new(value)
    end

  end

  def self.eval_function_call(context, function_result, parameter_asts)
    f = function_result.get
    values = parameter_asts.map {|p| p.eval(context).get }
    result = f.call(*values)
    LiteralResult.new(result)
  end

  class FunctionCallAST < Struct.new(:name, :parameters)

    def eval(context)
      SimpleLang.eval_function_call(context, VariableResult.new(context, name), parameters)
    end

  end

  UNARY_OPS = {
    '+' => proc {|x| x},
    '-' => proc {|x| -x},
    '!' => proc {|x| !x}
  }

  BINARY_OPS = {
    '==' => proc {|x, y| x == y},
    '!=' => proc {|x, y| x != y},
    '<' => proc {|x, y| x < y},
    '<=' => proc {|x, y| x <= y},
    '>' => proc {|x, y| x > y},
    '>=' => proc {|x, y| x >= y},
    '+' => proc {|x, y| x + y},
    '-' => proc {|x, y| x - y},
    '*' => proc {|x, y| x * y},
    '/' => proc {|x, y| x / y},
    '*' => proc {|x, y| x * y},
    '^' => proc {|x, y| x ^ y}
  }

  class UnaryOperationAST < Struct.new(:op, :right)

    def eval(context)
      unless UNARY_OPS.has_key?(op)
        raise ExecError.new("unknown unary operator")
      end
      right.eval(context).map(&UNARY_OPS[op])
    end

  end


  class BinaryOperationAST < Struct.new(:left, :op, :right)

    def eval(context)

      left_result = left.eval(context)

      if op == '.'
        case right
        when VariableAST
          return MemberResult.new(left_result, right.name)
        when FunctionCallAST
          return SimpleLang.eval_function_call(context, MemberResult.new(left_result, right.name), right.parameters)
        else
          raise ExecError.new("member name must be identifier")
        end
      else
        right_result = right.eval(context)
        if op == '='
          left_result.set(right_result.get)
          return left_result
        else
          unless BINARY_OPS.has_key?(op)
            raise ExecError.new("unknown binary operator")
          end
          return left_result.flat_map {|left_value|
            right_result.map {|right_value|
              BINARY_OPS[op].(left_value, right_value)
            }
          }
        end
      end

    end

  end

  class CaseWhenExpressionAST < Struct.new(:case_parameter, :when_statements, :else_procedure)

    def eval(context)

      case_value = case_parameter.eval(context).get

      when_statements.each do |statement|
        if case_value == statement.parameter.eval(context).get
          return statement.procedure.eval(context)
        end
      end

      if else_procedure
        return else_procedure.eval(context)
      end

      nil

    end

  end

  class Function

    attr_reader :context

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

      context = @context.push

      @parameters.each_with_index do |item, index|
        context[item] = parameters[index]
      end

      @procedure.eval(context).get
    end

    def to_s
      args = @parameters.inject do |memo, x|
        "#{memo}, #{x}"
      end
      "Function(#{args})"
    end

  end

  class FunctionLiteralAST < Struct.new(:parameters, :procedure)

    def eval(context)
      LiteralResult.new(Function.new(parameters, procedure, context))
    end

  end

end
