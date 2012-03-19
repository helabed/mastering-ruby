describe 'inherited in practice using shipping example in one file' do

  Dir.glob("shipping_*.rb").each do |name|
    require "./#{name}"
  end

  it "should be able to Ship 16oz domestic" do
    ShippingOption.shipping_options(16, false).sort{|a,b| a.to_s <=> b.to_s}.should == [FlatRatePriorityEnvelope, MediaMail]
  end

  it "should be able to Ship 90oz domestic" do
    ShippingOption.shipping_options(90, false).should == [MediaMail]
  end

  it "should be able to Ship 16oz international" do
    ShippingOption.shipping_options(16, true).sort.should == []
  end
end
