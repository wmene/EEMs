require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'json'

describe EemsController do
  before(:all) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
  end
  
  it "should be restful" do
    params_from(:post, "/eems/no_pdf").should == {:controller => 'eems', :action => 'no_pdf'}
  end
  
  describe "#no_pdf" do
    before(:each) do
      @eems_params = HashWithIndifferentAccess.new(
        {
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
          :title => 'title',
          :sourceUrl => 'http://something.org/papers',
        }
      )
      
      @eem = Eem.new(:pid => 'pid:123')
      @eem.set_properties(@eems_params.stringify_keys)
      @eem.should_receive(:save)

      Eem.should_receive(:from_params).with(@eems_params).and_return(@eem)
      Dor::WorkflowService.should_receive(:create_workflow).with('dor', 'pid:123', 'eemsAccessionWF', ACCESSION_WF_XML)
      
      @eem.should_receive(:add_datastream).with(an_instance_of(Dor::ActionLogDatastream))

      post "no_pdf", :eem => @eems_params, :wau => 'Willy Mene'
      
    end
    
    it "should create a new Eem from the params hash" do
     
    end
        
    it "should return json with just the eem pid" do
      json = JSON.parse(response.body)
      json.should == {
        'eem_pid' => 'pid:123',
        }
    end
    
    it "should create an ActionLog datastream" do
      
    end
    
  end
  
end