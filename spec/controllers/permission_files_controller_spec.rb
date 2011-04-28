require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PermissionFilesController do
  
  before(:each) do
    Fedora::Repository.stub!(:instance).and_return(stub('fedora').as_null_object)
    ActiveFedora::SolrService.stub!(:instance).and_return(stub('solr').as_null_object)
  end
  
  it "should be restful" do
    params_from(:post, "/eems/eem123/permission_files").should == {:controller => 'permission_files', :action => 'create',
                                                                          :eem_id => 'eem123'}
  end
  
  it "#destroy should delete a PermissionFile object and log that it was deleted" do
    @eem = Eem.new(:pid => 'my:pid123')
    log = Dor::ActionLogDatastream.new
    @eem.add_datastream(log)
    
    pf = PermissionFile.new
    pf.should_receive(:delete)
    
    props_ds = pf.datastreams['properties']
    props_ds.file_name_values = ['perm.pdf']
    
    PermissionFile.should_receive(:find).with('pfpid').and_return(pf)
    Eem.should_receive(:find).with('parentpid').and_return(@eem)
    
    session[:user_id] = 'wmene'
    delete "destroy", :eem_id => 'parentpid', :id => 'pfpid', :wau => 'Willy Mene'
    
    sleep 1
    log = @eem.datastreams['actionLog']
    log.each_entry do |ts, action, comment|
      ts.should < Time.new
      # Commented out for brittleness.  Depends on how authn/authz is handled in app controller
      # action.should == 'Permission file: perm.pdf deleted by Willy Mene'
    end
    
    response.should be_success
    response.should have_text('OK')
  end
  
  
  describe "#process_file" do
    it "should save a file to local disk and create a datastream for the content file" do
      file_stub = stub('stub_file', :original_filename => 'some_file.pdf', :size => 100000)
      eem_stub = stub('stub_eem', :pid => 'druid:123')
      props_ds =  mock('stub_props_ds').as_null_object 
      datastreams = {'properties' => props_ds }
      pf_stub = stub('stub_pf', :datastreams => datastreams, :save => true, :pid => 'druid:345')
      params = {:file => file_stub, :comment => "some comment"}
      
      controller.file = pf_stub
      controller.eem = eem_stub
      
      props_ds.should_receive(:comment_values=).with(["some comment"])
      
      #Save file to local disk
      File.should_receive(:exists?).and_return(true) 
      Dir.stub!(:mkdir)
      File.stub!(:open)
      
      #Create datastream for content
      mock_ds = mock('mock_datastream')
      ActiveFedora::Datastream.should_receive(:new).and_return(mock_ds)
      mock_ds.should_receive(:control_group=).with('E')
      mock_ds.should_receive(:versionable=).with(false)
      mock_ds.should_receive(:save)
      
      controller.process_file(params, "my dissertation")
    end
  end
    
  describe "#create_response" do
    before(:each) do
      controller.file_name = 'permission.pdf'
    end
    
    it "should create a hash with file name" do
      controller.create_response.should == {:file_name => 'permission.pdf'}
    end
    
    it "should redirect to /view/{parent_pid}" do
      
    end
    
  end
  
  describe "#log" do
    before(:each) do
      Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
      @eem = Eem.new(:pid => 'my:pid123')
      log = Dor::ActionLogDatastream.new
      @eem.add_datastream(log)
    end
    it "adds an entry to the action log saying whether the file was uploaded or deleted by the user" do

      Eem.should_receive(:find).with('my:pid123').and_return(@eem)
      controller.stub!(:process_file)
      controller.stub!(:create_response).and_return({})
 
      post :create, :eem_id => 'my:pid123', :file => stub('uploaded file', :original_filename => 'permission.pdf'), :wau => 'Willy Mene'
      
      sleep 1
      log = @eem.datastreams['actionLog']
      log.each_entry do |ts, action, comment|
        ts.should < Time.new
        # Commented out for brittleness.  Depends on how authn/authz is handled in app controller
        # action.should == 'Permission file: permission.pdf uploaded by Willy Mene'
      end
    end
  end
  
  
end