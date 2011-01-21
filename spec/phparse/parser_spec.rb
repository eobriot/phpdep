require 'spec_helper'

require 'parslet/rig/rspec'

describe Phparse::Phparser do
  let(:parser) { described_class.new}

  # context "Commentaires" do
  #   subject {parser.comment }
  #   it { should_not parse("// Yo mama").
  #     as({:commentaire => "yo mama"}) }

  #   it { should parse("//Yo mama\n").
  #     as({:commentaire => "Yo mama\n"}) }

  #   it { should parse("/*Yo mama*/").
  #     as({:commentaire => "Yo mama"}) }    
  # end
  context "Class" do
    subject {parser.class_def}
    #Class
    it {should parse("class toto {}").as({:class_mod => nil, :class_name => 'toto', :member => ''})}
    it {should_not parse("private class toto {}")}
    it {should parse("abstract class toto {}").as({:class_mod => 'abstract', :class_name => 'toto', :member => ''})}
    it {should parse("class toto extends tata {}").as({:class_mod => nil, :class_name => 'toto', :extends => 'tata', :member => ''})}
    it {should parse("class toto implements tata {}").as({:class_mod => nil, :class_name => 'toto', :implements => 'tata', :member => ''})}
    it {should parse("class toto extends tibi implements tata {}").as({:class_mod => nil, :class_name => 'toto', :extends => 'tibi', :implements => 'tata', :member => ''})}
    #Attributes
    it {should parse("class toto extends tibi implements tata { const $titi;}").as({:class_mod=>nil, :class_name=>"toto", :extends=>"tibi", :implements=>"tata", :member=>[{:attribute=>{:attr_mod =>"const", :var_name=>"titi"}}]})}
    it {should parse("class toto extends tibi implements tata { const $titi; $tata; private $tete;}").as({:class_mod=>nil, :class_name=>"toto", :extends=>"tibi", :implements=>"tata", :member=>[{:attribute=>{:attr_mod=>"const", :var_name=>"titi"}}, {:attribute=>{:attr_mod=>nil, :var_name=>"tata"}}, {:attribute=>{:attr_mod=>"private", :var_name=>"tete"}}]})}
    #Functions
    it {should parse("class toto { public function test() {}}").as({:class_mod=>nil, :class_name=>"toto", :member=>[{:method=>{:method_mod=>"public", :method_name=>"test"}}]})}
    it {should parse("class toto { public function test(DB $test, $titi) {}}").as({:class_mod=>nil, :class_name=>"toto", :member=>[{:method=>[{:method_mod=>"public", :method_name=>"test"}, {:parameter_type=>"DB", :var_name=>"test"}, {:parameter_type=>"", :var_name=>"titi"}]}]})}
  end
  
  context "Interface" do
    subject {parser.interface_def}
    #interfaces
    it { should parse("interface iTemplate {  public function setVariable($name, $var);
   public function getHtml($template);}").as({:interface_name=>"iTemplate", :method=>[{:method_mod=>"public", :method_name=>"setVariable"}, {:parameter_type=>"", :var_name=>"name"}, {:parameter_type=>"", :var_name=>"var"}, {:method_mod=>"public", :method_name=>"getHtml"}, {:parameter_type=>"", :var_name=>"template"}]})}

  end

  context "Method" do
    subject {parser.method}
    it {should parse("function test() {}").as({:method_mod=>nil, :method_name=>"test"})}
    it {should parse("function test(Toto $var) {}").as([{:method_mod=>nil, :method_name=>"test"}, {:parameter_type=>"Toto", :var_name=>"var"}])}
  end

  context "Return" do
    subject { parser.return_token}
    it {should parse("return;")}
    it {should parse("return $toto;").as({:expr=>{:variable => {:var_name=>"toto"}}})}
    it {should parse("return (DDB_VAR) $blah ;").as(:expr=>{:cast=>{:cast_type=>"DDB_VAR", :castee=>{:variable=>{:var_name=>"blah"}}}})}
  end

  context "Expression" do
    subject { parser.expr}
    it {should parse("$toto;").as({:variable => {:var_name=>"toto"}})}
    it {should parse("$toto ;").as({:variable => {:var_name=>"toto"}})}
    it {should parse("$toto = $titi;").as({:assignement =>{:left => {:var_name=>"toto"}, :right =>{:var_name=>"titi"}}})}
    it {should parse("(DDB_VAR) $blah ;").as({:cast=>{:cast_type=>"DDB_VAR", :castee=>{:variable=>{:var_name=>"blah"}}}})}

  end

end
