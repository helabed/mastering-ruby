describe 'Class Methods' do
  context "can be created with self" do
    class Dave
      def self.say_hello
        "Hi"
      end
    end
    it "should be called without an instance" do
      expect(Dave.say_hello).to eq "Hi"
    end
  end
  context "can be created with class << self when declaring more than one method at once" do
    class Dave
      class << self
        def say_hello
          "Hi"
        end
      end
    end
    it "should be called without an instance" do
      expect(Dave.say_hello).to eq "Hi"
    end
  end
end
