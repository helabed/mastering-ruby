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
      expect(David.count).to eq 0
      David.new
      David.new
      expect(David.count).to eq 2
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
      expect(Dave.count).to eq 0
      Dave.new
      Dave.new
      expect(Dave.count).to eq 2
    end
  end
end
