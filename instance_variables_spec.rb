describe 'instance variables' do
  context "are private to the object that created them" do
    class MyInstanceVarsClass
      def initialize(x, y)
        @x, @y = x, y
      end
    end
    it "should not allow access from the outside without a getter" do
      my_class = MyInstanceVarsClass.new(2,5)
      expect {
        my_class.x}.to raise_error(NoMethodError)
    end
    it "should allow access from the outside only when a getter is defined" do
      MyInstanceVarsClass.class_eval { attr_reader :x } # adding getter instance method to x
      my_class = MyInstanceVarsClass.new(2,5)
      expect(my_class.x).to eq 2
    end
    it "should not allow modification from the outside without a setter" do
      my_class = MyInstanceVarsClass.new(2,5)
      expect {
        my_class.x = 6}.to raise_error(NoMethodError)
    end
    it "should allow modification from the outside only when a setter is defined with help of class_eval and attr_writer" do
      MyInstanceVarsClass.class_eval { attr_writer :x; attr_reader :x; } # adding setter/getter instance methods to x
      my_class = MyInstanceVarsClass.new(2,5)
      my_class.x= 7
      expect(my_class.x).to eq 7
    end
    it "should allow modification from the outside only when a setter is defined with help of class_eval and attr_accessor" do
      my_class = MyInstanceVarsClass.new(2,5)
      my_class.class.class_eval { attr_accessor :x; }
      my_class.x= 8
      expect(my_class.x).to eq 8
    end
  end
end
