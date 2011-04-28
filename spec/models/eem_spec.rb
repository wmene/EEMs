require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe Eem do
  before(:all) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
  end
  
  before(:each) do
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
    @eem = Eem.new(:pid => 'my:pid123')
    Eem.stub!(:new).and_return(@eem)
    @eem.stub!(:save)
    
    @submitted_eem = HashWithIndifferentAccess.new({
      :copyrightStatusDate => '1/1/10',
      :copyrightStatus => 'pending',
      :creatorName => 'Joe Bob',
      :creatorType => 'person',
      :language => 'English',
      :note => 'text of note',
      :paymentType => 'free|paid',
      :paymentFund => 'BIOLOGY',
      :selectorName => 'Bob Smith',
      :selectorSunetid => 'bsmith',
      :title => 'Digital Content Title',
      :sourceUrl => 'http://something.org/papers',
      :requestDatetime => 'sometimestamp'
    })
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @eem.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a eemsProperties datastream" do
    @eem.datastreams['eemsProperties'].should_not be_nil
  end
  
  it "should have a DC datastream" do
    @eem.datastreams['DC'].should_not be_nil
  end
  
  it "should have access to permission files" do
    @eem.should respond_to(:permission_files)
  end
  
  it "should have get and set properties" do
    props_ds = @eem.datastreams['eemsProperties']
    props_ds.note_values = ['a note to myself']
    props_ds.copyrightStatusDate_append('10-22-10')
    
    xml = props_ds.to_xml
    xml.should =~ /<note>a note to myself<\/note>/
    xml.should =~ /<copyrightStatusDate>10-22-10<\/copyrightStatusDate>/
  end
  
  describe "creator initialization" do
    
    it "should initialize an eem with a creator type of person" do
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      props = eem.datastreams['eemsProperties']
      props.creatorPerson_values.should == ['Joe Bob']
      props.creatorOrg_values.should == []
    end
    
    it "should initialize an eem with a creator type of organziation" do
      @submitted_eem[:creatorType] = 'organization'
      @submitted_eem[:creatorName] = 'US Geological Survey'
      
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      props = eem.datastreams['eemsProperties']
      props.creatorPerson_values.should == []
      props.creatorOrg_values.should == ['US Geological Survey']
    end
  end
  
  describe "labels" do

    
    it "should set the fedora object label to 'EEMs: {title}" do
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      eem.label.should == 'EEMs: Digital Content Title'
    end
  end
  
  describe "Dublin Core" do
    it "should be initialized with creator, title, and identifier" do
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      
      dc = eem.datastreams['DC']
      dc.creator_values.should == ['Joe Bob']
      dc.identifier_values.should == ['my:pid123']
      dc.title_values.should == ['Digital Content Title']
    end
    
    it "should handle either personCreator or orgCreator" do
      @submitted_eem[:creatorType] = 'organization'
      @submitted_eem[:creatorName] = 'US Geological Survey'
      
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      dc = eem.datastreams['DC']
      dc.creator_values.should == ['US Geological Survey']
      dc.identifier_values.should == ['my:pid123']
      dc.title_values.should == ['Digital Content Title']
    end
  end
  
  describe "#generate_initial_identity_metadata_xml" do
    before(:each) do
      @id_xml =<<-EOF
        <identityMetadata>
          <objectId>my:pid123</objectId>                                  
          <objectType>item</objectType>
          <objectAdminClass>EEMs</objectAdminClass>                                           
          <agreementId>druid:fn200hb6598</agreementId>                            
          <tag>EEM : 1.0</tag>                                 
        </identityMetadata>
      EOF
      
      @submitted_eem = HashWithIndifferentAccess.new({
        :copyrightStatusDate => '1/1/10',
        :copyrightStatus => 'pending',
        :creatorName => 'Joe Bob',
        :creatorType => 'person',
        :language => 'English',
        :note => 'text of note',
        :paymentType => 'free|paid',
        :paymentFund => 'BIOLOGY',
        :selectorName => 'Bob Smith',
        :selectorSunetid => 'bsmith',
        :title => 'Digital Content Title',
        :sourceUrl => 'http://something.org/papers',
        :requestDatetime => 'sometimestamp'
      })
    end
    
    it "should initially create identityMetdata with objectId, ojbectType, objectAdminClass, agreementId and tag" do      
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      
      # until we switch to 1.8.7, we have to set our expectation this cheap way
      eem.generate_initial_identity_metadata_xml.should == "<?xml version=\"1.0\"?>\n<identityMetadata>\n  <objectId>my:pid123</objectId>\n  <objectType>item</objectType>\n  <objectAdminClass>EEMs</objectAdminClass>\n  <agreementId>some:objectId</agreementId>\n  <tag>EEM : 1.0</tag>\n</identityMetadata>\n"
      
    end
  end
  
  
end
