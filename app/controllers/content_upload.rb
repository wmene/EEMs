
# Contains common methods used by the EemsController and PartsController when uploading content
module ContentUpload
  
  def create_content_dir
    @content_dir = File.join(Sulair::WORKSPACE_DIR, @eem.pid)
    FileUtils.mkdir(@content_dir) unless (File.exists?(@content_dir))
  end
  
  # Assumes params[:content_upload], @content_dir, @log, and @eem, and @user are defined
  # Create a new Part if it doesn't exist already
  # Otherwise, a previous upload attempt failed, so use the existing Part
  def create_part_from_upload_and_log
    content_file = params[:content_upload]
    
    if(@eem.parts.size == 0)
      part = Part.from_params()
      part.add_relationship(:is_part_of, @eem)
      part.save
      Rails.logger.info("Creating new Part: #{part.pid}")
    else
      part = @eem.parts.first
      Rails.logger.info("Using existing Part: #{part.pid}")
      
      props_ds = part.datastreams['properties']
      Rails.logger.warn("!!!!! Replacing existing Part content !!!!!!") if(props_ds.done_values.first =~ /true/i)
    end
    
    filename = Part.normalize_filename(content_file.original_filename)
    File.open(File.join(@content_dir,filename), "wb") { |f| f.write(content_file.read) }
    
    part.create_content_datastream(filename)
    part.download_done

    @log.log("File uploaded by #{@user.display_name}")
    @log.save
  end
  
end