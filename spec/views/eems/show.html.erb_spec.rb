require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Eems show page" do
  before(:all) do
    ActiveFedora::SolrService.register(SOLR_URL)
    Fedora::Repository.register(FEDORA_URL)
    Fedora::Repository.stub!(:instance).and_return(stub('frepo').as_null_object)
  end
  
  before(:each) do
    @parts_params = {
      :url => 'http://somesite.com/a.pdf',
      :content_file_id => 12
    }
    
    @p = Part.new(:pid => 'my:pid123')
    @p.stub!(:save)
  end

  it "should render the fields of an Eem" do
    @eem_params = {
      :copyrightStatusDate => '1/1/10',
      :copyrightStatus => 'pending',
      :creatorOrg => 'text from creator field',
      :creatorPerson => 'creator person',
      :language => 'English',
      :note => 'text of note',
      :paymentType => 'free|paid',
      :paymentFund => 'BIOLOGY',
      :selectorName => 'Bob Smith',
      :selectorSunetid => 'bsmith',
      :title => 'some title for the eem',
      :sourceUrl => 'http://something.org/papers',
      :requestDatetime => '1/10/10'
    }
    our_eem = Eem.new
    Eem.stub!(:new).and_return(our_eem)
    our_eem.stub!(:save)
    
		eem = Eem.from_params(@eem_params)
		
		part = Part.from_params(@parts_params)
		part.stub!(:save)
    part.add_relationship(:is_part_of, @eem)

    assigns[:eem] = eem
    assigns[:parts] = [part]
    
    render "eems/show.html.erb"
    
    response.body.should =~ /<h1.*class=\"mainTitle\".*>some title for the eem<\/h1>/i
    response.body.should =~ /<option value=\"person\" selected=\"selected\">person<\/option>/i
  end
end
