require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'curl'
require 'active_fedora'
require 'tempfile'
require 'dor/download_job'

describe Dor::DownloadJob do
  before(:each) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
    
  end
    
  describe "perform" do
    before(:each) do
      FileUtils.mkdir(File.join(Sulair::WORKSPACE_DIR, 'druid:123')) unless (File.exists?(File.join(Sulair::WORKSPACE_DIR, 'druid:123')))
      
      @cf = ContentFile.new
      @cf.url = 'http://stanford.edu/images/stanford_title.jpg'
      @cf.filepath = File.join(Sulair::WORKSPACE_DIR, 'druid:123')
      @cf.user_display_name = 'Willy Mene'
      @cf.part_pid = 'part:123'
      
      @part = Part.from_params(:url => @cf.url, :content_file_id => 12)
      @part.stub!(:save)
      @part.stub!(:parent_pid).and_return('parent:pid')
      
      ContentFile.stub!(:find).and_return(@cf)
      Part.should_receive(:find).with(@cf.part_pid).and_return(@part)
      
      # Setup an Eem with an ActionLog
      # The Eem is the parent of this Part object
      eem = Eem.new(:pid => 'druid:123')
      @log = Dor::ActionLogDatastream.new
      eem.add_datastream(@log)
      @part.add_relationship(:is_part_of, eem)
      Eem.should_receive(:find).with('parent:pid').and_return(eem)
      
      job = Dor::DownloadJob.new(1)
      job.perform
    end
        
    it "creates the content datastream setting done and filename" do
      @part.datastreams.has_key?('content').should be_true
      @part.datastreams['properties'].done_values.should == ['true']
      @part.datastreams['properties'].filename_values.should == ['stanford_title.jpg']
    end
    
    it "logs that the download is complete" do
      @log.entries.size.should == 1
      @log.entries.first[:action].should == 'File uploaded by Willy Mene'
    end
    
    context "downloaded content file" do
      before(:each) do
        @filepath = File.join(@cf.filepath, 'stanford_title.jpg')
      end
      
      it "copies the downloaded file to the workspace" do
        File.file?(@filepath).should be_true
      end
      
      it "sets the file permissions for owner read/write and read only for group and world" do
        sprintf("%o", File.stat(@filepath).mode).should == "100644"
      end
      
    end
    
    after(:each) do
      FileUtils.rm_rf(File.join(Sulair::WORKSPACE_DIR, 'druid:123'))
    end
  end
  
  describe "error handling" do
    it "should increment the number of attempts if an exception is thrown" do
      
      cf = ContentFile.new
      cf.url = 'http://stanford.edu/images/stanford_title.jpg'
      cf.attempts = 1
            
      ContentFile.stub!(:find).and_return(cf)
      Tempfile.should_receive(:new).and_raise(Exception.new)
      job = Dor::DownloadJob.new(1)
      cf.should_receive(:attempts=).with(2)
      cf.should_receive(:save)
      lambda{ job.perform }.should raise_exception
            
    end
    
    it "should not set attempts to greater than 5" do
      
      cf = ContentFile.new
      cf.url = 'http://stanford.edu/images/stanford_title.jpg'
      cf.attempts = 5
            
      ContentFile.stub!(:find).and_return(cf)
      Tempfile.should_receive(:new).and_raise(Exception.new)
      job = Dor::DownloadJob.new(1)
      cf.should_not_receive(:attempts=)
      cf.should_not_receive(:save)
      job.should_not be_nil
      lambda{ job.perform }.should raise_exception
            
    end
    
    it "should throw an exception if the download fails" do
      cf = ContentFile.new
      cf.url = 'http://lyberservices-dev.stanford.edu/junk'
      cf.attempts = 1

      ContentFile.stub!(:find).and_return(cf)
      job = Dor::DownloadJob.new(1)
      lambda{ job.perform }.should raise_exception
    end
  end
end