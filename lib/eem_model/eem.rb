# Copied from internal Stanford gem

module EemModel

  class Eem < ActiveFedora::Base
  
    has_relationship "parts", :is_part_of, :inbound => true #content files

    has_metadata :name => 'eemsProperties', :type => ActiveFedora::MetadataDatastream do |m|
      m.label = "eemsProperties"

      m.field "copyrightStatusDate", :string, :multiple => false #mutiple doesn't do anything
      m.field "copyrightStatus", :string
      m.field "creatorOrg", :string
      m.field "creatorPerson", :string
      m.field "language", :string
      m.field "note", :string
      m.field "paymentType", :string
      m.field "paymentFund", :string
      m.field "selectorName", :string
      m.field "selectorSunetid", :string
      m.field "title", :string
      m.field "sourceUrl", :string
      m.field "requestDatetime", :string
      m.field "status", :string
      m.field "statusDatetime", :string
      m.field "downloadDate", :string
    end
    
    has_metadata :name => "DC", :type => ActiveFedora::QualifiedDublinCoreDatastream do |m|
    end

  end
  
end

