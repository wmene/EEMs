require 'vendor/plugins/blacklight/app/controllers/application_controller.rb'
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  before_filter :set_current_user
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  protected
  
  # For the purposes of distribution, this method will create an eems_demo_user for logging in.
  # It will be up to the developer to re-write this method 
  def set_current_user
    # !!!!!!!!!!!!!!!!!!!!!!!! Setting a demo user
    # !!!!!!!!!!!!!!!!!!!!!!!! Replace these lines with institution specific authorization/authentication scheme
    unless EemsUser.user_authenticated?(session)
      user = EemsUser.new("Eems Demo User created in ApplicationController", 'eems_demo_user', 'privgroup unused')
      user.save_to_session(session)
    end
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  private
    def require_fedora
      Fedora::Repository.register(FEDORA_URL,  session[:user])
      return true
    end
    def require_solr
      ActiveFedora::SolrService.register(SOLR_URL)
    end

    # underscores are escaped w/ + signs, which are unescaped by rails to spaces
    # html tags are escaped by converting < and > to &lt; and &gt;
    def unescape_keys(attrs)
      h=Hash.new
      attrs.each do |k,v|
        v = v.gsub(/</, '&lt;')
        v = v.gsub(/>/, '&gt;')
        h[k.gsub(/ /, '_')] = v
      end
      h
    end
    
    def escape_keys(attrs)
      h=Hash.new
      attrs.each do |k,v|
        h[k.gsub(/_/, '+')]=v
      end
      h
    end
    
    # !!!!!!!!!!!!!!!!!!!!!!!! These filters should be re-written/removed for institution specfic authentication/authorization
    def user_required
      true
    end

    # 
    def authorized_user
      true
    end
  
end
