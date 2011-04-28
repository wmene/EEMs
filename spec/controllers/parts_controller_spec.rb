require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PartsController do
  
  before(:each) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
    
    @file = File.new(File.join(RAILS_ROOT, 'tmp', 'pre%20space.pdf'), "w+")
    @file.stub!(:original_filename).and_return(@file.path.split(/\//).last)
    
    @eem = Eem.new(:pid => 'pid:123')
    Eem.stub!(:find).with('pid:123').and_return(@eem)
    
    @user = EemsUser.new('Willy Mene', 'wmene')
    @user.save_to_session(session)
    request.env['WEBAUTH_LDAPPRIVGROUP'] = Sulair::AUTHORIZED_EEMS_PRIVGROUP
    
    @log = Dor::ActionLogDatastream.new
    @eem.stub_chain(:datastreams, :[]).and_return(@log)
  end
  
  after(:each) do
    FileUtils.rm(@file.path)
  end
  
  it "is restful" do
    params_from(:post, "/eems/druid:123/parts").should == {:controller => 'parts', :action => 'create', :eem_id => 'druid:123'}                                                                     
  end
  
  describe "#create" do
    context "when a Part object DOES NOT exist for the Eem (the normal case)" do
      
      before(:each) do
        @eem.should_receive(:parts).and_return([])
        
        @part = Part.new(:pid => 'part:345')
        @part.stub!(:save)
        Part.should_receive(:new).and_return(@part)

        post "create", :eem_id => 'pid:123', :content_upload => @file, :wau => 'Willy Mene'
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
        @log.entries.size.should == 1
        entry = @log.entries.first
        entry[:action].should == "File uploaded by Willy Mene"
      end

      it "redirects to the /view path" do
        response.should redirect_to("/view/#{@eem.pid}")
      end
    end
    
    context "when a Part object exists for the EEM (upload after failure)" do
      
      before(:each) do
        @part = Part.new(:pid => 'part:345')
        @part.stub!(:save)
        
        # It is already part of the Eem
        @part.add_relationship(:is_part_of, @eem)
        @eem.stub!(:parts).and_return([@part])
      end

      it "does not create a new Part object" do
        Part.should_not_receive(:new)

        post "create", :eem_id => 'pid:123', :content_upload => @file, :wau => 'Willy Mene'
      end
      
      it "creates the content datastream with dsLocation pointing to files location in the workspace" do
        post "create", :eem_id => 'pid:123', :content_upload => @file, :wau => 'Willy Mene'
        
        content_ds = @part.datastreams['content']
        content_ds[:dsLocation].match(/#{Sulair::WORKSPACE_URL}\/pid:123\/pre space.pdf/).should_not be_nil
      end
    end    
  end
end