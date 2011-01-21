module Phparse

  

end

require "phparse/phparse"

def launch prog
    parser = Phparse::Phparser.new
    begin
      parser.parse prog
    rescue Parslet::ParseFailed => error
      puts error, parser.root.error_tree
    end
  end
