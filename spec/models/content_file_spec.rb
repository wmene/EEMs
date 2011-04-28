require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContentFile do
  it "should calculate progress from curl's dl_total and dl_now values" do
    @cf = ContentFile.new
    @cf.update_progress(100, 33)
    @cf.percent_done.should == 33
  end
end