describe 'Object based inheritance or prototypal inheritance' do
  context "methods can be created from object instances" do
    animal = "cat"
    def animal.speak
      "miaow"
    end

    it "methods can be called from the instance" do
      animal.speak.should == "miaow"
    end
    it "a cloned object inherits the instance methods" do
      other_animal = animal.clone
      other_animal.speak.should == "miaow"
    end
    it "a duplicated object does not inherit the instance methods" do
      other_animal = animal.dup
      p = lambda { other_animal.speak }
      p.should raise_error(NoMethodError, "undefined method `speak' for \"cat\":String")
    end
  end
  context "cloned objects also inherit the state of the cloned object" do
    animal = Object.new
    def animal.number_of_feet=(feet)
      @number_of_feet = feet
    end
    def animal.number_of_feet
      @number_of_feet
    end

    cat = animal.clone
    cat.number_of_feet = 4

    it "instance variables are cloned also" do
      felix = cat.clone
      felix.number_of_feet.should == 4
    end
  end
end
