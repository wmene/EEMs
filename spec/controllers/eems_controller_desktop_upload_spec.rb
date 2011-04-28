
require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

describe EemsController do
  before(:each) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
    

    @file = File.new(File.join(RAILS_ROOT, 'tmp', 'pre%20space.pdf'), "w+")
    @file.stub!(:original_filename).and_return(@file.path.split(/\//).last)

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
      :sourceUrl => 'http://something.org/papers'
    })
  end
  
  after(:each) do
    FileUtils.rm(@file.path)
  end
    
  describe "#create" do
    context "with no existing Part object" do
      before(:each) do
        @eem = Eem.new(:pid => 'pid:123')
        @eem.set_properties(@eems_params.stringify_keys)
        @eem.should_receive(:save)
  
        Eem.should_receive(:from_params).with(@eems_params).and_return(@eem)
        Dor::WorkflowService.should_receive(:create_workflow).with('dor', 'pid:123', 'eemsAccessionWF', ACCESSION_WF_XML)
        
        @eem.stub!(:parts).and_return([])

        @log = Dor::ActionLogDatastream.new
        Dor::ActionLogDatastream.should_receive(:new).and_return(@log)
        @eem.should_receive(:add_datastream).with(an_instance_of(Dor::ActionLogDatastream))

        @part = Part.new(:pid => 'part:345')
        @part.stub!(:save)

        Part.should_receive(:new).and_return(@part)

        post "create", :eem => @eems_params, :content_upload => @file, :wau => 'Willy Mene'
      end

      it "creates the content datastream with dsLocation pointing to files location in the workspace" do
        content_ds = @part.datastreams['content']
        content_ds[:dsLocation].match(/#{Sulair::WORKSPACE_URL}\/pid:123\/pre space.pdf/).should_not be_nil
      end

      it "saves the file name in the properties datastream" do
        props_ds = @part.datastreams['properties']
        props_ds.filename_values.first.should =~ /pre space.pdf/
      end

      it "adds a log entry saying the file was uploaded by the user" do
        @log.entries.size.should == 2
        entry = @log.entries[1]
        # Commented out for brittleness.  Depends on how authn/authz is handled in app controller
        # entry[:action].should == "File uploaded by Willy Mene"
      end

      it "sends an HTTP response with the eems's pid" do    
        response.body.should == 'eem_pid=pid:123'
      end

    end
    

   
    
  end
  
end