require 'active_fedora'
require 'nokogiri'
require 'time'

module Dor
  class ActionLogDatastream < ActiveFedora::Datastream
    attr_accessor :entries
    
    def initialize(attrs=nil)
      super
      self.label = "Action Log"
      self.dsid = "actionLog"
      self.control_group = 'X'
      self.versionable = false
      @entries = []
    end
    
    def save
      self.blob = self.to_xml
      super
    end

    def log(action, comment = nil)
      entry = {:timestamp => Time.new, :action => action}
      entry[:comment] = comment unless(comment.nil?)
      @entries << entry
    end

    def each_entry(&block)
      @entries.each do |entry|
        block.call(entry[:timestamp], entry[:action], entry[:comment])
      end
    end
    
    ########################################################################
    # Fedora datastream marshalling
    
    # Build an ActionLog from the Fedora persisted instance
    # tmpl ActiveFedora::Datastream
    # node   Nokogiri::Node
    def self.from_xml(tmpl, node)
      entries = []
      node.xpath("./foxml:datastreamVersion[last()]/foxml:xmlContent/actionLog/entry").each do |entry_node|
        entry = {:timestamp => Time.parse(entry_node["timestamp"]), 
                 :action => entry_node.at_xpath("./action").text}
        comment = entry_node.at_xpath("./comment")
        entry[:comment] = comment.text if(comment)
        entries << entry
      end
      
      #TODO maybe sort by timestamp?
      tmpl.entries = entries
      tmpl
    end
    
    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.actionLog {
          self.each_entry do |ts, action, comment|
            xml.entry(:timestamp => ts.xmlschema) {
              xml.action action
              xml.comment comment unless(comment.nil?)
            }
          end
        }
      end
      builder.to_xml
    end
    
    
  end
end