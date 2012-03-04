describe 'Class Methods' do
  context "can be created with self" do
    class Dave
      def self.say_hello
        "Hi"
      end
    end
    it "should be called without an instance" do
      Dave.say_hello.should == "Hi"
    end
  end
  context "can be created with class << self" do
    class Dave
      class << self
        def say_hello
          "Hi"
        end
      end
    end
    it "should be called without an instance" do
      Dave.say_hello.should == "Hi"
    end
  end
end

