require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'active_fedora'


describe Part do
  before(:all) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
  end
  
  before(:each) do
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
    
    @parts_params = {
      :url => 'http://somesite.com/a.pdf',
      :content_file_id => 12
    }
    
    @p = Part.new(:pid => 'my:pid123')
    @p.stub!(:save)
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @p.should be_kind_of(ActiveFedora::Base)
  end
      
  it "should initialize with url, content_file_id, and set done to false " do
    part = Part.from_params(@parts_params)
    props = part.datastreams['properties']
    props.url_values.should  == ['http://somesite.com/a.pdf']
    props.content_file_id_values.should == ['12']
    props.done_values.should == ['false']
  end
    
  it "download_done should set done properties field to true" do
    part = Part.from_params(@parts_params)
    part.download_done
    
    props_ds = part.datastreams['properties']
    props_ds.done_values.should == ['true']
  end
    
  describe "create_content_datastream" do
    before(:each) do
      @eem = Eem.new(:pid => 'druid:123')
      @eem.stub!(:save)
      
      @part = Part.from_params(@parts_params)
      @part.stub!(:save)
      @part.add_relationship(:is_part_of, @eem)
      
      @part.create_content_datastream('a.pdf')
    end
    
    #TODO might have to change for files that aren't retrieved with GET
    it "should create the content datastream using the url it already contains and save it" do
      content_ds = @part.datastreams['content']
      content_ds[:dsLocation].should == Sulair::WORKSPACE_URL + '/druid:123/a.pdf'
    end
    
    it "should save the filename in the properties datastream" do
      props_ds = @part.datastreams['properties']
      props_ds.filename_values.first.should == 'a.pdf'
    end
    
    it "should not create the content datastream if it exists already" do
       props = @part.datastreams['properties']
       props.url_values = ['http://somesite.com/b.pdf']
       
       @part.create_content_datastream('a.pdf')
       
       content_ds = @part.datastreams['content']
       content_ds[:dsLocation].should == Sulair::WORKSPACE_URL + '/druid:123/a.pdf'
    end
  end
  
  it "should create itself without passing in a params hash" do

    part = Part.from_params()
    props = part.datastreams['properties']
    props.url_values.should  == []
    props.content_file_id_values.should == []
    props.done_values.should == ['false']
    
  end
  
  it "#normalize_filename should url-decode strings" do
    Part.normalize_filename('file%20with%20space%20.blah').should == "file with space .blah"
  end
  
  it "#log_download_complete should an entry to the parent Etd saying 'PDF uploaded by {user}'" do
    @eem = Eem.new(:pid => 'druid:123')
    @log = Dor::ActionLogDatastream.new
    @eem.add_datastream(@log)
    @eem.stub!(:save)
    
    @part = Part.from_params(@parts_params)
    @part.stub!(:save)
    @part.add_relationship(:is_part_of, @eem)
    
    @part.stub!(:parent_pid).and_return('druid:123')
    Eem.should_receive(:find).with('druid:123').and_return(@eem)
    
    @part.log_download_complete('Display Name')
    
    @log.entries.size.should == 1
    @log.entries.first[:action].should == 'File uploaded by Display Name'
  end
  
end
