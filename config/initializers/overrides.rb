

require 'fedora/base'
require 'fedora/repository'
require 'net/http'
require 'net/https'

class Fedora::Datastream < Fedora::BaseObject
  def versionable
    @attributes[:versionable]
  end
  
  def versionable=(new_val)
    @attributes[:versionable]=new_val
  end
  
end

module ActiveFedora
  class Base
    def delete
      Fedora::Repository.instance.delete(@inner_object)
      SolrService.instance.conn.delete(self.pid) if ENABLE_SOLR_UPDATES
    end
  end
  
  class MetadataDatastream < Datastream

    #constructor, calls up to ActiveFedora::Datastream's constructor
    def initialize(attrs=nil)
      super
      @fields={}
      self.versionable = false
    end
    
   
    #this is to order the xml into an alphabetical order. 
    def to_xml(xml = Nokogiri::XML::Document.parse("<fields />")) #:nodoc:
      if xml.instance_of?(Nokogiri::XML::Document)
        xml_insertion_point = xml.root
      else
        xml_insertion_point = xml.sort
      end
      builder = Nokogiri::XML::Builder.with(xml_insertion_point) do |xml|
        f = fields.sort {|a,b| a[0].to_s <=> b[0].to_s}
        f.each do |value|
          field = value[0]
          field_info = value[1]
          element_attrs = field_info[:element_attrs].nil? ? {} : field_info[:element_attrs]
          field_info[:values].each do |val|
              builder_arg = "xml.#{field}(val, element_attrs)"
              puts builder_arg.inspect
              eval(builder_arg)
          end #do |val|
        end #each do |value|
      end #builder
      return builder.to_xml
    end #def to_xml
    
  end #class
end #module

#Patch after upgrade to Rails 2.3.2
#See http://groups.google.com/group/rack-devel/browse_thread/thread/4bce411e5a389856
module Mime
  class Type
    def split(*args)
      to_s.split(*args)
    end
  end
end
