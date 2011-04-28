require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'active_fedora'

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
  end
  
  describe "#update_identity_metadata_object_label" do
    before(:each) do
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
    
    it "should add an objectLabel node to an existing identityMetadata datastream" do
      id_xml =<<-EOF
        <identityMetadata>
          <objectId>my:pid123</objectId>                                  
          <objectType>item</objectType>
          <objectAdminClass>EEMs</objectAdminClass>                                           
          <agreementId>druid:fn200hb6598</agreementId>                            
          <tag>EEM : 1.0</tag>                                 
        </identityMetadata>
      EOF
      
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      id_ds = eem.datastreams['identityMetadata']
      id_ds.stub!(:content).and_return(id_xml)
      id_ds.should_receive(:content=).with(/<objectLabel>EEMs: Digital Content Title<\/objectLabel>/)
      id_ds.stub!(:save)
      
      eem.update_identity_metadata_object_label
    end
    
    it "should swap the current objectLabel if it's value does not match the current Fedora object label" do
      id_xml =<<-EOF
        <identityMetadata>
          <objectId>my:pid123</objectId>                                  
          <objectType>item</objectType>
          <objectAdminClass>EEMs</objectAdminClass>
          <objectLabel>EEMs: Old Title</objectLabel>                                           
          <agreementId>druid:fn200hb6598</agreementId>                            
          <tag>EEM : 1.0</tag>                                 
        </identityMetadata>
      EOF
      
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      id_ds = eem.datastreams['identityMetadata']
      id_ds.stub!(:content).and_return(id_xml)
      id_ds.should_receive(:content=).with(/<objectLabel>EEMs: Digital Content Title<\/objectLabel>/)
      id_ds.stub!(:save)
      
      eem.update_identity_metadata_object_label
    end
    
    it "should create the identityMetadata datastream if it doesn't exist, then add objectLabel" do
      eem = Eem.from_params(@submitted_eem.stringify_keys)
      id_ds = eem.datastreams['identityMetadata']
      id_ds.stub!(:content).and_return(nil)
      id_ds.should_receive(:content=).with("<?xml version=\"1.0\"?>\n<identityMetadata>\n  <objectId>my:pid123</objectId>\n  <objectType>item</objectType>\n  <objectLabel>EEMs: Digital Content Title</objectLabel>\n  <objectAdminClass>EEMs</objectAdminClass>\n  <agreementId>some:objectId</agreementId>\n  <tag>EEM : 1.0</tag>\n</identityMetadata>\n")
      id_ds.stub!(:save)
      
      eem.update_identity_metadata_object_label
    end
  end
end