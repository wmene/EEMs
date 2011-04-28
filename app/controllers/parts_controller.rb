
class PartsController < ApplicationController
  include ContentUpload
  
  before_filter :require_fedora
  before_filter :require_solr
  before_filter :user_required
  before_filter :authorized_user
  
  # Handles POST to /eems/:eems_id/parts
  def create
    @eem = Eem.find(params[:eem_id])
    @log = @eem.datastreams['actionLog']
    @user = EemsUser.load_from_session(session)
    
    create_content_dir
    
    # The file was uploaded with the POST
    if(!params[:content_upload].nil?) 
      create_part_from_upload_and_log
      
      redirect_to "/view/#{@eem.pid}"
    else
      # We shouldn't get here, so log an error if we
      Rails.logger.error("!!!!! There was no content uploaded !!!!!!")
    end
    
  end
  
  # Handles PUT to /eems/:eems_id/parts/:id
  def update
    @eem = Eem.find(params[:eem_id])
    part = @eem.parts.first
    attrs = unescape_keys(params[:part])
        
    logger.debug("attributes submitted: #{attrs.inspect}")
    part.update_attributes(attrs)
    part.save
    
    response = {'part' => attrs}
    logger.debug("returning #{response.inspect}")
    render :json => response    
  end
  
end