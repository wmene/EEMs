require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe " New Login view" do
  it "should display a link to /login/webauth" do
    params[:referrer] = 'http://cnn.com'
    render "login/new.html.erb"
    
    response.body.should =~ /href=\'\/login\/webauth\/\?referrer/
  end
end