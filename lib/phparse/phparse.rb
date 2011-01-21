# -*- coding: utf-8 -*-
require 'parslet'

class Phparse::Phparser < Parslet::Parser
  root(:program)
  rule :script do
    str("<?php") >> space_or_eol >> program >>  space_or_eol >>str("?>")
  end
 
  # Règles génériques
  rule :eol do
    match('\r').repeat | match('\r\n').repeat | match('\n').repeat
  end

  rule :space do
    match('\s').repeat
  end

  rule :word do
    space.maybe >> match('\w') >> space.maybe
  end

  rule :line do
    word.repeat >> eol.maybe
  end

  rule :space_or_eol do
    space.maybe | space.maybe >> eol.maybe
  end
  # Grammaire
   rule(:program) do
    statement.repeat >> space_or_eol.maybe
  end

  rule :statement do
#    class_def.as(:class_def) | interface_def.as(:interface_def)
    interface_def.as(:interface_def)|  class_def.as(:class_def) | method.as(:method)| return_token.as(:return_token) | expr.as(:expr)
    #| static_declaration | global
    # | try_token | throw_token | eval_expr
    # | if_token | while_token | do_token
    # | for_token | foreach_token  | switch_token
    # | break_token | continue_token | declare_token | nop
  end

  # class definition
  rule :class_def do
    class_mod.maybe.as(:class_mod) >> space_or_eol >> str('class') >> space_or_eol >> match('\w').repeat.as(:class_name) >> space_or_eol >> extends.maybe >> space_or_eol >> implements.maybe  >> space_or_eol >> str('{') >> space_or_eol >> member.repeat.as(:member) >> space_or_eol >> str('}') >> space_or_eol
  end

  rule :class_mod do
    str('abstract') | str('final')
  end

  rule :extends do
    str('extends') >> space >> match('\w').repeat.as(:extends)
  end

  rule :implements do
    str('implements') >> space >> match('\w').repeat.as(:implements)
  end

  #class member
  rule :member do
    #method | attribute
    space >> method.as(:method) | space >> attribute.as(:attribute)
  end

  rule :method do
    signature >> space_or_eol.maybe >> str(';') >> space_or_eol.maybe | signature >> space_or_eol.maybe >> str('{') >> space_or_eol.maybe >> str('}') >> space_or_eol.maybe # statement.repeat >>
  end
  
  rule :signature do
    method_mod.maybe.as(:method_mod) >> space >> str('function') >> space >> match('\w').repeat.as(:method_name) >> space >> str('(') >> space >> formal_parameters.repeat >> space >> str(')')
  end

  rule :method_mod do
    str('public') | str('protected') | str('private') | str('static') | str('abstract') | str('final')
  end

  rule :formal_parameters do
    match('\w').repeat.maybe.as(:parameter_type) >> space >> variable_decl >> str(',').maybe
  end

  #Variables and attributes
  rule :variable_decl do
      variable >>space >> str('=') >> space >> match('\w').repeat.as(:var_value) | str('$') >> match('\w').repeat.as(:var_name) 
  end

  rule :variable do
     str('$') >> match('\w').repeat.as(:var_name) | str('$') >> match('\w').repeat.as(:var_name) >> space_or_eol >> str(";") >> space_or_eol
  end

  rule :attribute do
    attr_mod.maybe.as(:attr_mod) >> space.maybe >> variable_decl >> space.maybe >> str(';')
  end
  
  rule :attr_mod do
    str('private') | str('protected') | str('private') | str('static') | str('const') 
  end

  #Interfaces

  rule :interface_def do
     str('interface') >> space >> match('\w').repeat.as(:interface_name) >> space >> extends.maybe >> space_or_eol >> str('{') >> space_or_eol >> method.repeat.as(:method) >> space_or_eol >> str('}') >> space_or_eol
  end

  #return
  rule :return_token do
     str('return') >> space >> str(";") >> eol.maybe | str('return') >> space >> expr.maybe.as(:expr) 
  end
  
 #Expression...Le pire.
  rule :expr do
    assignement.as(:assignement) | cast.as(:cast)  | space >> variable.as(:variable) >> space >> str(";").maybe
  end

  rule :assignement do
    variable.as(:left) >> space >> str('=') >> space >> variable.as(:right)  >> space >> str(';') >> eol.maybe
  end

  rule :cast do
    space >> str('(') >> space >> match('\w').repeat.as(:cast_type) >> space >> str(')') >> space >> expr.as(:castee)
  end

end
