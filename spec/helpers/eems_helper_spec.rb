require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EemsHelper do
  
  describe "#eems_text_field_tag" do
    it "should generate the html for an eem property using the field name and text" do
      html =<<-EOF
      <p>
          <%= text_field_tag 'eem[note]' %>
          <input id="eem_note" name="eem[note]" type="text" value=""/>
      </p>
      EOF
      
      out = helper.eems_text_field_tag(:note)
      out.should =~ /<input id=\"eem_note\" name=\"eem\[note\]\" type=\"text\" value=\"\" \/>/      
    end
  end
  
  describe "#get_source_url" do
    it "should return a URL or an empty string for a given referrer object" do
      helper.get_source_url('https://jirasul.stanford.edu/jira/browse/EEMS-13').should == 'https://jirasul.stanford.edu/jira/browse/EEMS-13'
      helper.get_source_url(nil).should == ""      
    end 
  end  

  describe "#shorten_url" do
    it "should return a shortened URL (if length is less than 40 chars) for a given URL" do
      helper.shorten_url('http://www.irs.gov/app/picklist/list/formsPublications.html').should == 'http://www.irs.gov/app/picklist/list/for...'
      helper.shorten_url('http://www.stanford.edu/01.pdf').should == 'http://www.stanford.edu/01.pdf'      
    end 
  end  
  
  describe "#get_local_file_path" do
    it "returns a URI with a url-encoded filename" do
      parts = stub('parts')
      eem = stub('eem')
      eem.stub!(:pid).and_return('etd:123')
      assigns[:parts] = parts
      assigns[:eem] = eem
      parts.stub_chain(:[], :datastreams, :[], :filename_values, :first).and_return('file some space.pdf')
      
      helper.get_local_file_path.should == Sulair::WORKSPACE_URL + '/etd:123/file%20some%20space.pdf'
    end
  end
  
  describe "#print_url_decoded" do
    before(:each) do
      @parts = stub('parts')
      eem = stub('eem')
      eem.stub!(:pid).and_return('etd:123')
      assigns[:parts] = @parts
      assigns[:eem] = eem
    end
    
    it "should url-decode the url to the original content" do
      @parts.stub_chain(:[], :datastreams, :[], :url_values, :first).and_return('http://research-repository.st-andrews.ac.uk/bitstream/10023/967/1/The%20Segur%20Reform%20of%20the%20French%20Army%20_Bien_.pdf')
    
      helper.print_url_decoded.should == 'http://research-repository.st-andrews.ac.uk/bitstream/10023/967/1/The Segur Reform of the French Army _Bien_.pdf'
    end
    
    it "should url-decode an empty string without failing" do
      @parts.stub_chain(:[], :datastreams, :[], :url_values, :first).and_return('')
    
      helper.print_url_decoded.should == ''
    end
    
    it "should url-decode nil without failing" do
      @parts.stub_chain(:[], :datastreams, :[], :url_values, :first).and_return(nil)
    
      helper.print_url_decoded.should == ''
    end
  end
    
end
