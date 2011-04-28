require 'dor/workflow_service'

class EemsController < ApplicationController
  include ContentUpload
  
  before_filter :require_fedora
  before_filter :require_solr
  
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
  # These filters are defined in the local ApplicationController
  # Either they should be re-written for institution specfic authentication/authorization
  before_filter :user_required, :except => :index
  before_filter :authorized_user, :except => :index
  
  #GET /eems
  def index
    render :text => 'OK'
  end
  
  #GET /eems/{:id}
  def show
    @user = EemsUser.load_from_session(session)   
    @eem = Eem.find(params[:id])
    @parts = @eem.parts
    
    render :layout => "eems_show"
  end
  
  #GET /eems/new
  #render the page to create a new Eem
  def new
    @user = EemsUser.load_from_session(session)  
  end
  
  #POST /eems
  #Handles submit from /eems/new
  #Assume we receive the standard Rails hash of all the form params
  def create
    create_eem_and_log
    create_content_dir
    
    # The file was uploaded with the POST
    if(!params[:content_upload].nil?) 
      create_part_from_upload_and_log
      
      #render_creation_response(@eem.pid, part.pid)
      res = 'eem_pid=' + @eem.pid
      render :text => res.to_s, :content_type => 'text/plain'
    
    # We will download the file in the background  
    else
      cf = ContentFile.new
      cf.url = params[:contentUrl]
      
      cf.filepath = @content_dir
      cf.attempts = 1
      cf.user_display_name = @user.display_name
      cf.save
    
      part = Part.from_params(:url => params[:contentUrl], :content_file_id => cf.id)
      part.add_relationship(:is_part_of, @eem)
      part.save
      cf.part_pid = part.pid
      cf.save
      
      job = Dor::DownloadJob.new(cf.id)
      Delayed::Job.enqueue(job)
      
      render_creation_response(@eem.pid, part.pid, cf.id)
    end
        
  end
  
  #POST /eems/no_pdf
  def no_pdf
    create_eem_and_log
    render_creation_response(@eem.pid)
  end
  
  # Taken from Salt project
  # Uses the update_indexed_attributes method provided by ActiveFedora::Base
  # This should behave pretty much like the ActiveRecord update_indexed_attributes method
  # For more information, see the ActiveFedora docs.
  # 
  # Examples
  # put :update, :id=>"_PID_", "document"=>{"subject"=>{"-1"=>"My Topic"}}
  # Appends a new "subject" value of "My Topic" to any appropriate datasreams in the _PID_ document.
  # put :update, :id=>"_PID_", "document"=>{"medium"=>{"1"=>"Paper Document", "2"=>"Image"}}
  # Sets the 1st and 2nd "medium" values on any appropriate datasreams in the _PID_ document, overwriting any existing values.
  def update
    @eem = Eem.find(params[:id])
    attrs = unescape_keys(params[:eem])
    logger.debug("attributes submitted: #{attrs.inspect}")
    ###@eem.update_indexed_attributes(attrs)
    @eem.update_attributes(attrs)
    @eem.save
    
    ###response = attrs.keys.map{|x| escape_keys({x=>attrs[x].values})}
    response = {'eem' => attrs}
    logger.debug("returning #{response.inspect}")
    render :json => response
  end
  
  protected
  def create_eem_and_log
    @eem = Eem.from_params(params[:eem])
    attrs = unescape_keys(params[:eem])
    @eem.update_attributes(attrs)
    
    @user = EemsUser.load_from_session(session)
    #Add actionLog datastream
    @log = Dor::ActionLogDatastream.new
    @log.log("Request created by #{@user.display_name}")
    @eem.add_datastream(@log)
    @eem.save
    
    #Create the workflow datastream
    #It's defined in config/initializers/accession_workflow_config
    Dor::WorkflowService.create_workflow('dor', @eem.pid, 'eemsAccessionWF', ACCESSION_WF_XML)
  end
  
  def render_creation_response(eem_pid, part_pid=nil, content_file_id=nil)
    resp = {'eem_pid' => @eem.pid}
    resp['part_pid'] = part_pid unless(part_pid.nil?)
    resp['content_file_id'] = content_file_id unless(content_file_id.nil?)
      
    render :json => resp.to_json
  end
  
end