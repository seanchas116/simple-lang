
require 'pp'
require 'simple-lang/parser'
require 'simple-lang/ast'
require 'simple-lang/transform'
require 'simple-lang/context'

module SimpleLang

  class Engine

    attr_reader :builtin_vars

    def initialize(io = STDOUT)
      @io = io
      @builtin_vars = Hash[]
      @builtin_vars["print"] = proc {|x| io.puts x.to_s}
    end

    def parse(source, print_parsetree: false, print_ast: false)
      parsed = Parser.new.parse(source)
      if print_parsetree
        pp parsed
      end
      ast = Transform.new.apply(parsed)
      if print_ast
        pp ast
      end
      ast
    rescue Parslet::ParseFailed => failure
      @io.puts failure.cause.ascii_tree
    end

    def run(source, print_parsetree: false, print_ast: false)
      ast = parse(source, print_parsetree: print_parsetree, print_ast: print_ast)
      if Procedure === ast
        context = Context.new.push(@builtin_vars)
        ast.eval(context)
      end
    rescue ExecError => failure
      @io.puts failure.message
    end

  end

end