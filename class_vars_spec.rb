describe 'Class Variables' do
  context "can be created with self" do
    class David
      @count = 0
      def self.count
        @count
      end
      def self.count=(new_count)
        @count = new_count
      end
      def initialize
        David.count = David.count + 1
        super
      end
    end
    it "should be called without an instance" do
      David.count.should == 0
      d1 = David.new
      d2 = David.new
      David.count.should == 2
    end
  end
  context "can be created with class << self" do
    class Dave
      class << self
        attr_accessor :count
      end

      @count = 0

      def initialize
        Dave.count += 1
        super
      end
    end
    it "should be called without an instance" do
      Dave.count.should == 0
      d1 = Dave.new
      d2 = Dave.new
      Dave.count.should == 2
    end
  end
end

