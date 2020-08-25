describe 'a Ruby method' do
  context "always return the last statement executed" do
    class WizzardInstance
      def self.close_over_wizard(param)
        "Hi"
        if (param)
          "hello"
        else
          "good bye"
        end
      end
    end
    it "should return the last statememnt from if block when an if{...} statement is truthy" do
      expect(WizzardInstance.close_over_wizard(true)).to eq "hello"
    end
    it "should return the last statememnt from else block when an if{...} statement is falsy" do
      expect(WizzardInstance.close_over_wizard(false)).to eq "good bye"
    end
    class WizzardInstance2
      def self.close_over_wizard(param)
        "Hi"
        if (param)
          "hello"
        end
      end
    end
    it "should return nil when we have 'if (nil)' as the last statement and no else block" do
      expect(WizzardInstance2.close_over_wizard(nil)).to eq nil
    end
    it "should return last statement in else block when we have if (nil) as the last statement" do
      expect(WizzardInstance.close_over_wizard(nil)).to eq "good bye"
    end
  end
end
