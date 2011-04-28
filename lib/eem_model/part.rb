# Copied from internal Stanford gem

module EemModel

  class Part < ActiveFedora::Base
  
    has_relationship "parents", :is_part_of #relationship between content file and parent Eem

    has_metadata :name => 'properties', :type => ActiveFedora::MetadataDatastream do |m|
      m.label = "properties"
      m.field "url", :string
      m.field "done", :string
      m.field "content_file_id", :string
      m.field "filename", :string
      m.field "download_date", :string
    end
  
  end

end

