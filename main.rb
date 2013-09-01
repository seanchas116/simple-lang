require 'pp'
require './parser.rb'

def parse(str)
  parsed = Parser.new.parse(str)
  pp parsed
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

parse("1 + a(1) + 2 + (s + -t)")
