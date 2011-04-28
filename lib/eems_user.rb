class EemsUser

  attr_reader :display_name, :login, :privgroup
  
  def initialize(display_name, login, privgroup=nil)
    @display_name = display_name
    @login = login
    @privgroup = privgroup
  end
  
  def save_to_session(session)
    u = {:display_name => @display_name, :login => @login, :privgroup => @privgroup}
    session[:eems_user] = u
  end
  
  # TODO what to do when there is no :eems_user in the session
  def EemsUser.load_from_session(session)
    u = EemsUser.new(session[:eems_user][:display_name], session[:eems_user][:login], session[:eems_user][:privgroup])
    u
  end
  
  def EemsUser.user_authenticated?(session)
    return true unless(session[:eems_user].nil?)
    false
  end
  
  #For backwards compatibility
  alias :sunetid :login
  
end