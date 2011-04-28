require File.dirname(__FILE__) + '/../spec_helper'

describe PermissionFile do
  before(:all) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
  end
  
  before(:each) do
    ActiveFedora::Base.stub_chain(:instance, :delete)
    ActiveFedora::SolrService.stub_chain(:instance, :conn, :delete)
    Fedora::Repository.stub!(:instance).and_return(stub('stub').as_null_object)
    
    @eem = Eem.new
    @eem.stub!(:pid).and_return("pid:345")
    
    @pf = PermissionFile.new
    @pf.add_relationship(:is_dependent_of, @eem)
    @pf.stub!(:create_date).and_return("2008-07-02T05:09:42.015Z")
    @pf.stub!(:modified_date).and_return("2008-09-29T21:21:52.892Z")
    @pf.stub!(:save)
  
    @pf.datastreams['properties'].file_name_values = ["some_file.pdf"]
  end
  
  it "should respond to #permission_file_for" do
    @pf.should respond_to(:permission_file_for)
  end
  
  it "should have versionable set to false for the properties datastream" do
    @pf.datastreams['properties'].versionable.should be_false
  end
  
  describe "#delete" do
    
    before(:each) do
      @pf.stub!(:permission_file_for).and_return([@eem.pid])
      FileUtils.should_receive(:rm).with(Sulair::WORKSPACE_DIR + "/#{@eem.pid}/some_file.pdf")
      Dir.stub!(:glob).and_return(["filename"])
    end
    
    it "should remove the files of its content datastream" do
      @pf.delete
    end
    
    it "should delete the parent directory if it is empty after deleting the content file" do
      Dir.should_receive(:glob).with(Sulair::WORKSPACE_DIR + "/#{@eem.pid}/*").and_return([])
      Dir.should_receive(:rmdir).with(Sulair::WORKSPACE_DIR + "/#{@eem.pid}")
      
      @pf.delete
    end
    
    it "should not delete the parent directory if it is not empty after deleting the content file" do
      Dir.should_receive(:glob).with(Sulair::WORKSPACE_DIR + "/#{@eem.pid}/*").and_return(["somefile"])
      Dir.should_not_receive(:rmdir)
      
      @pf.delete
    end
  

  end
 
  it "#set_permission_file_titles should put the parent ETD pid in Fedora label and DC.title" do
    p = PermissionFile.new
    p.add_relationship(:is_dependent_of, @eem)
    p.datastreams['properties'].comment_values = ['Some comment']
    p.set_permission_file_titles
    
    p.label.should == 'Permission file for Eem pid:345'
    p.datastreams['DC'].title_values.first.should == 'Permission file for Eem pid:345'
  end 
end