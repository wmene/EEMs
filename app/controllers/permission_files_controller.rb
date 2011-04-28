
class PermissionFilesController < ApplicationController
  include ApplicationHelper
  
  before_filter :require_fedora
  before_filter :require_solr
  before_filter :user_required
  before_filter :authorized_user
  
  #before_filter :duplicate_file_check, :only => [:create, :create_supplemental, :create_permission]
  #before_filter :upload_size_check, :only => [:create, :create_supplemental, :create_permission]
  
  attr_accessor :file, :file_name, :eem
  
  # Handles http POST  
  def create
    @file= PermissionFile.new()
    @eem = Eem.find(params[:eem_id])
    @file.add_relationship(:is_dependent_of, @eem)
    @file.set_permission_file_titles
    process_file(params, "Permission File")
    
    log_uploaded
    response = create_response

    redirect_to "/view/#{@eem.pid}"
  end
  
  # Handles http DELETE
  def destroy
    part = PermissionFile.find(params[:id])
    if(part.nil?)
      render :status => 404, :text => "Cannot find object with id: #{params[:id]}"
    else
      part.delete
      @eem = Eem.find(params[:eem_id])
      log_deleted(part)
      render :text => 'OK'
    end
  end
  
  #for stubbing
  def create_new_datastream(attrs)
    ds = ActiveFedora::Datastream.new(attrs)
  end
  
  def create_response
    {:file_name => @file_name}
  end
    
  def process_file(params, label = "")
    @file_name = params[:file].original_filename
    props_ds = @file.datastreams['properties']
    props_ds.file_name_values = [@file_name]
    mime_type = MIME::Types.type_for(@file_name).to_s
    props_ds.comment_values = [params[:comment]] if(params[:comment])
    @file.save
        
    #save file to local disk.  Directory is pid of parent object
    dir = Sulair::WORKSPACE_DIR + "/#{@eem.pid}"
    Dir.mkdir(dir) unless (File.exists?(dir))
    @path = File.join(dir, @file_name)
    File.open(@path, "wb") { |f| f.write(params[:file].read) }
    
    #create externally managed Fedora Datastream
    url = Sulair::WORKSPACE_URL + "/#{@eem.pid}/#{@file_name}"
    #save file as a datastream for this new child object
    attrs = {:pid => @file.pid, :dsID => 'content', :dsLocation => url, 
      :mimeType => mime_type, :dsLabel => label, :checksumType => 'MD5' }
    @datastream = ActiveFedora::Datastream.new(attrs)
    @datastream.control_group = 'E'
    @datastream.versionable = false
    @datastream.save
  end
  
  def log_uploaded
    log('uploaded', params[:file].original_filename)
  end
  
  def log_deleted(permfile)
    log('deleted', permfile.datastreams['properties'].file_name_values.first)
  end
  
  def log(action, file_name)
    user = EemsUser.load_from_session(session)
    log = @eem.datastreams['actionLog']
    log.log("Permission file: #{file_name} #{action} by #{user.display_name}")
    log.save
  end

  
  def upload_size_check
    if(params[:file].size.to_i > MAX_UPLOADED_FILE_SIZE)
      render :status => 400, :text => 'error-400-file-too-large'
      return false
    end
    true
  end
  
  def duplicate_file_check
    if(File.exists?(WORKSPACE_DIR + '/' + params[:submit_id] + '/' + params[:file].original_filename))
      Rails.logger.error('File already exists')
      render :status => 400, :text => 'error-400-file-exists'
      return false
    end
    true
  end


end
