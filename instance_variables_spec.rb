describe 'instance variables' do
  context "are private to the object that created them" do
    class MyInstanceVarsClass
      def initialize(x, y)
        @x, @y = x, y
      end
    end
    it "should not allow access from the outside without a getter" do
      my_class = MyInstanceVarsClass.new(2,5)
      lambda {
        my_class.x}.should raise_error(NoMethodError)
    end
    it "should allow access from the outside only when a getter is defined" do
      MyInstanceVarsClass.class_eval { attr_reader :x }
      my_class = MyInstanceVarsClass.new(2,5)
      my_class.x.should == 2
    end
    it "should not allow modification from the outside without a setter" do
      my_class = MyInstanceVarsClass.new(2,5)
      lambda {
        my_class.x = 6}.should raise_error(NoMethodError)
    end
    it "should allow modification from the outside only when a setter is defined with help of class_eval and attr_writer" do
      MyInstanceVarsClass.class_eval { attr_writer :x; attr_reader :x; }
      my_class = MyInstanceVarsClass.new(2,5)
      my_class.x= 7
      my_class.x.should == 7
    end
    it "should allow modification from the outside only when a setter is defined with help of class_eval and attr_accessor" do
      my_class = MyInstanceVarsClass.new(2,5)
      my_class.class.class_eval { attr_accessor :x; }
      my_class.x= 8
      my_class.x.should == 8
    end


  end

end
