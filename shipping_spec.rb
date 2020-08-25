describe 'inheritance in practice using shipping example in one file' do
  context 'using different shipping types' do

    before(:all) do
      Dir.glob("shipping_*.rb").each do |name|
        require "./#{name}"
      end
    end

    it "should be able to Ship 16oz domestic" do
      expect(ShippingOption.shipping_options(16, false).sort{|a,b| a.to_s <=> b.to_s}).to eq [FlatRatePriorityEnvelope, MediaMail]
    end

    it "should be able to Ship 90oz domestic" do
      expect(ShippingOption.shipping_options(90, false)).to eq [MediaMail]
    end

    it "should be able to Ship 16oz international" do
      expect(ShippingOption.shipping_options(16, true).sort).to eq []
    end
  end
end
