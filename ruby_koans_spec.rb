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
      WizzardInstance.close_over_wizard(true).should == "hello"
    end
    it "should return the last statememnt from else block when an if{...} statement is falsy" do
      WizzardInstance.close_over_wizard(false).should == "good bye"
    end
    class WizzardInstance2
      def self.close_over_wizard(param)
        "Hi"
        if (param)
          "hello"
        end
      end
    end
    it "should return nil when we have if (nil) as the last statement and no else block" do
      WizzardInstance2.close_over_wizard(nil).should == nil
    end
    it "should return last statement in else block when we have if (nil) as the last statement" do
      WizzardInstance.close_over_wizard(nil).should == "good bye"
    end
  end
end

