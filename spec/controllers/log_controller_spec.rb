require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LogController do
  it "should be restful" do
    params_from(:post, "/eems/23/log").should == {:controller => 'log', :action => 'create', :eems_id => "23"}
  end
  
  
  context "POST handling" do
    before(:all) do
      ActiveFedora::SolrService.register(SOLR_URL)
      Fedora::Repository.register(FEDORA_URL)
    end

    before(:each) do
      Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
      @eem = Eem.new(:pid => 'my:pid123')
      log = Dor::ActionLogDatastream.new
      @eem.add_datastream(log)
    end
    
    # It can handle json 
    # {"entry": "My log entry text", "comment": "My comment about this entry"}
    # 
    # Or xml
    # <log>
    #  <entry>My xml entry</entry>
    #  <comment>My comment about this entry</comment>
    # </log>
    #
    # Or application/x-www-form-urlencoded
    #  entry=My%20text

    it "Handles posted xml and adds log entry" do

      
      Eem.should_receive(:find).with('my:pid123').and_return(@eem)
      
      post "create", :entry => "My log entry", :comment => 'Saying something', :eems_id => 'my:pid123'
      
      sleep 1
      log = @eem.datastreams['actionLog']
      log.each_entry do |ts, action, comment|
        ts.should < Time.new
        action.should == 'My log entry'
        comment.should == 'Saying something'
      end
      
      response.should be_success
      response.status.should == "200 OK"
    end
    
    it "Handles posted xml without comment" do
      Eem.should_receive(:find).with('my:pid123').and_return(@eem)
      
      post "create", :entry => "My log entry", :eems_id => 'my:pid123'
      
      sleep 1
      log = @eem.datastreams['actionLog']
      log.each_entry do |ts, action, comment|
        ts.should < Time.new
        action.should == 'My log entry'
        comment.should be_nil
      end
      
      response.should be_success
      response.status.should == "200 OK"
    end
    
  end
  
  
  
  
end