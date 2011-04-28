require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'dor/action_log_datastream'

describe Dor::ActionLogDatastream do
  
  context "adding entries and displaying the log" do
    
    it "#log appends a new log entry" do
      act_log = Dor::ActionLogDatastream.new
      act_log.log("I did something")
      sleep 1
            
      act_log.each_entry do |timestamp, log_entry|
        timestamp.should < Time.new
        log_entry.should == "I did something"
      end
    end
    
    it "#each_entry returns entries in FIFO order" do
      act_log = Dor::ActionLogDatastream.new
      act_log.log("first action")
      sleep 1
      act_log.log("second action")
      
      timestamps, text = [], []
      act_log.each_entry do |timestamp, log_entry|
        timestamps << timestamp
        text << log_entry
      end
      
      timestamps[0].should < timestamps[1]
      text[0].should == "first action"
      text[1].should == "second action"
      
    end
    
    describe "comment parameter" do
      
      it "#log handles optional comment parameter" do
        act_log = Dor::ActionLogDatastream.new
        act_log.log("I did something", "It was really neat when I did it")
        sleep 1

        act_log.each_entry do |timestamp, log_entry, comment|
          timestamp.should < Time.new
          log_entry.should == "I did something"
          comment.should == "It was really neat when I did it"
        end
      end
      
      it "#log should still work without passing in a comment" do
        act_log = Dor::ActionLogDatastream.new
        act_log.log("I did something")
        sleep 1

        act_log.each_entry do |timestamp, log_entry, comment|
          timestamp.should < Time.new
          log_entry.should == "I did something"
          comment.should be_nil
        end
      end
    end
    
    
    
  end
  
  context "Marshalling to and from a Fedora Datastream" do
    before(:each) do      
      @dsfoxml =<<-EOF
      <foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#">
        <foxml:datastreamVersion>
          <foxml:xmlContent>
            <actionLog>
              <entry timestamp="2010-05-25T14:06:38-07:00">
                <action>First action</action>
                <comment>This was done initially</comment>
              </entry>
              <entry timestamp="2010-05-25T15:06:38-07:00">
                <action>Second action</action>
                <comment>This was done last</comment>
              </entry>
              <entry timestamp="2010-05-25T16:06:38-07:00">
                <action>Third action</action>
              </entry>
            </actionLog>
          </foxml:xmlContent>
        </foxml:datastreamVersion>
      </foxml:datastream>
      EOF
    end
    
    it "can create itself from fedora datastream xml" do
      doc = Nokogiri::XML(@dsfoxml).root
      ds = Dor::ActionLogDatastream.from_xml(Dor::ActionLogDatastream.new, doc)
      
      timestamps, actions, comments = [], [], []
      ds.each_entry do |timestamp, action, comment|
        timestamps << timestamp
        actions << action
        comments << comment unless(comment.nil?)
      end
      
      timestamps[0].should == Time.parse('2010-05-25T14:06:38-07:00')
      timestamps[1].should == Time.parse('2010-05-25T15:06:38-07:00')
      timestamps[2].should == Time.parse('2010-05-25T16:06:38-07:00')
      actions[0].should == "First action"
      actions[1].should == "Second action"
      actions[2].should == "Third action"
      comments[0].should == "This was done initially"
      comments[1].should == "This was done last"
      comments.size.should == 2
    end
    
    it "can marshall itself to xml" do
      act_xml = <<-EOF
      <actionLog>
        <entry timestamp="2010-05-25T14:06:38-07:00">
          <action>First action</action>
          <comment>Hi there</comment>
        </entry>
        <entry timestamp="2010-05-25T15:06:38-07:00">
          <action>Second action</action>
          <comment>Hola</comment>
        </entry>
        <entry timestamp="2010-05-25T16:06:38-07:00">
          <action>Third action</action>
        </entry>
      </actionLog>
      EOF
      
      ds = Dor::ActionLogDatastream.new
      entries = []
      entries << {:timestamp => Time.parse('2010-05-25T14:06:38-07:00'), :action => "First action", :comment => "Hi there"}
      entries << {:timestamp => Time.parse('2010-05-25T15:06:38-07:00'), :action => "Second action", :comment => "Hola"}
      entries << {:timestamp => Time.parse('2010-05-25T16:06:38-07:00'), :action => "Third action"}
      ds.entries = entries
      
      expected = XmlSimple.xml_in(act_xml)
      generated = XmlSimple.xml_in(ds.to_xml)
      generated.should == expected
    end
    
    it "handles marshalling of no log entries" do
      ds = Dor::ActionLogDatastream.new
      expected = XmlSimple.xml_in("<actionLog/>")
      generated = XmlSimple.xml_in(ds.to_xml)
      generated.should == expected
    end
    
    
  end
end