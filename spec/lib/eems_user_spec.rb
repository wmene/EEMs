require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EemsUser do
  it "generates a display name" do
    u = EemsUser.new('first last', 'login')
    u.display_name.should == 'first last'
  end
  
  it "stores the WEBAUTH_LDAPPRIVGROUP" do
    u = EemsUser.new('first last', 'login', 'sulair:eems-users')
    u.privgroup.should == 'sulair:eems-users'
  end
  
  it "does not have a #find method" do
    EemsUser.should_not respond_to(:find)
  end
  
  it "does not have a #valid? method" do
    EemsUser.should_not respond_to(:valid?)
  end
  
  context ".load_from_session" do
    it "loads an EemsUser from the session" do
      u = {:display_name => "display name", :login => 'sun123', :privgroup => 'sulair:eems-users'}
      session = {:eems_user => u}
      
      user = EemsUser.load_from_session(session)
      user.display_name.should == 'display name'
      user.login.should == 'sun123'
      user.privgroup.should == 'sulair:eems-users'
    end
    
    it "loads an EemsUser without privgroup" do
       u = {:display_name => "display name", :login => 'sun123'}
        session = {:eems_user => u}

        user = EemsUser.load_from_session(session)
        user.display_name.should == 'display name'
        user.login.should == 'sun123'
        user.privgroup.should_not be
    end
  end
  
  context "#save_to_session" do
    it "saves itself to the passed in session" do
      sess = {}
      u = EemsUser.new('first last', 'idsunet', 'mygroup')
      u.save_to_session(sess)
      u_hash = sess[:eems_user]
      u_hash[:display_name].should == 'first last'
      u_hash[:login].should == 'idsunet'
      u_hash[:privgroup].should == 'mygroup'
    end
    
    it "saves itself to the passed in session without a privgroup" do
      sess = {}
      u = EemsUser.new('first last', 'idsunet')
      u.save_to_session(sess)
      u_hash = sess[:eems_user]
      u_hash[:display_name].should == 'first last'
      u_hash[:login].should == 'idsunet'
      u_hash[:privgroup].should_not be
    end
  end
  
  context ".user_authenticated?" do
    it "returns true if an EemsUser has been loaded into the session" do
      u = {:display_name => "display name", :login => 'sun123'}
      session = {:eems_user => u}
      
      EemsUser.user_authenticated?(session).should be_true
    end
    
    it "returns false if an EemsUser has not been loaded into the session" do
      session = {}      
      EemsUser.user_authenticated?(session).should be_false
    end
    
  end
  
end