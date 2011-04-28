
class PermissionFile < ActiveFedora::Base
  
  has_relationship "permission_file_for", :is_dependent_of          # relationship between permission file and parent etd
    
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "file_name", :string
    m.field "comment", :string
  end

  has_metadata :name => "DC", :type => ActiveFedora::QualifiedDublinCoreDatastream do |m|
  end
    
  def parent_pid
    permission_file_for(:response_format => :id_array)[0]
  end
  
  def path_to_file 
    file_name = datastreams['properties'].file_name_values.first
    File.join(Sulair::WORKSPACE_DIR, parent_pid, file_name)
  end
  
  def delete
    super
    FileUtils.rm(path_to_file)    
    Dir.rmdir( Sulair::WORKSPACE_DIR + "/#{parent_pid}" ) if(Dir.glob(Sulair::WORKSPACE_DIR + "/#{parent_pid}/*").empty?)
  end
  
  def set_permission_file_titles
    set_dc_and_fedora_metadata('Permission file for Eem ' << parent_pid)
  end
  
  private
  def set_dc_and_fedora_metadata(title)
    self.label = title
    datastreams['DC'].title_values = title
  end
  
end