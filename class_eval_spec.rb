describe 'class_eval or module_eval' do
  context 'allows us to execute any code inside a block where the receiver is a class or a module' do
    it "should execte any code where the receiver is a class" do
      String.class_eval do
        self
      end.should == String
    end
    it "should execte any code where the receiver is a module" do
      module MyModule
      end
      MyModule.class_eval do
        self
      end.should == MyModule
    end
  end

  context 'allows us to define methods inside a block' do
    it "should allow us to define instance methods on the class itself" do
      String.class_eval do
        def as_a_cat
          "kitty says: #{self}"
        end
      end
      my_string = String.new("Hello people")
      my_string.as_a_cat.should == 'kitty says: Hello people'
      # or any other string object
      "miaow".as_a_cat.should == 'kitty says: miaow'
    end
    it "everytime we call class_eval on a class, ruby places the "+
        "newly defined methods(instance methods) inside it, and makes it the current class of the receiver of class_eval" do
      true.should == true
    end
    it "class_eval would declare instance methods, because class_eval can be called only on classes and modules in ruby - the name reflects the receiver" do
      true.should == true
    end
    it "instance_eval would declare class methods, because instance_eval can be called on every single object in ruby - the name reflects the receiver" do
      true.should == true
    end
    it "see file 'receiver_a_class__class_eval__creates_instance_methods.png' to find out what the 'def' method does inside class_eval" do
      true.should == true
    end
    it "see file 'receiver_a_class__instance_eval__creates_class_methods.png' to find out what the 'def' method does inside instance_eval" do
      true.should == true
    end
    it "see file 'receiver__xxx_eval__truth_table.png' to find out what the 'def' method does for all cases" do
      true.should == true
    end
  end
  context 'allows us to define methods or code inside a class given a class object' do
    it "should allow us to define instance methods on the class itself" do
      module Hello
        def say_hello
          "Hi from: #{self.inspect}"
        end
      end
      #class String
      #  include Hello
      #end
      [String, Array, Hash].each do |cls|
        cls.class_eval { include Hello }
      end

      "miaow".say_hello.should == 'Hi from: "miaow"'
      [1,2,3].say_hello.should == 'Hi from: [1, 2, 3]'
      {:key => 'value'}.say_hello.should == 'Hi from: {:key=>"value"}'
    end
  end
end
