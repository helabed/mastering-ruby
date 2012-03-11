describe 'instance_eval' do
  context 'allows us to execute any code inside a block - unlike eval' do
    it "should execte any code" do
      instance_eval do
        'hello'
      end.should == 'hello'
    end
    it "should execte any code with a receiver - unlike eval which is a private method" do
      "cat".instance_eval do
        self
      end.should == 'cat'
    end
    it "inside the block of the receiver 'self' is set to the receiver of instance_eval" do
      "cat".instance_eval do
        upcase
      end.should == 'CAT'
    end
    context "allow us to cheat and access instance variables without a getter or a setter" do
      before(:all) do
        class MyClass
          def initialize
            @the_var = 66
          end

          private

            def secret
              'my private secret'
            end
        end
        @m = MyClass.new
      end
      it "without instance_eval we should not be able to access the instance variable" do
        lambda {@m.the_var}.should raise_error(NoMethodError)
      end
      it "with instance_eval we should be able to access the instance variable" do
        @m.instance_eval do
          @the_var
        end.should == 66
        @m.instance_eval do
          @the_var = 'the_cat'
          @the_var
        end.should == 'the_cat'
      end
      it "without instance_eval we should not be able to access private methods" do
        lambda {@m.secret}.should raise_error(NoMethodError)
      end
      it "with instance_eval we should be able to access private methods - i.e methods without a receiver" do
        @m.instance_eval do
          secret
        end.should == 'my private secret'
      end
      it "instance_eval with a block produces a closure but not as we expect in that inside the block self is changed to the receiver of instance_eval" do
        class Other
          def method1(thing)
            thing.instance_eval do
              method2 # will always be called on self as a receiver
            end
          end
          def method2
          end
          def method3(thing)
            thing.instance_eval do
              @the_var = 55
            end
          end
        end
        obj = Other.new
        lambda {obj.method1(@m)}.should raise_error(NameError)
        obj.method3(@m).should == 55
      end
    end
  end
  context 'allows us to define methods inside a block' do
    it "should allow us to define methods on any instance of a class" do
      animal = "cat"
      animal.instance_eval do
        def speak
          'miaow'
        end
      end
      animal.speak.should == 'miaow'
    end
    it "everytime we call instance_eval on an object, ruby creates an anonymous ghost class and places the "+
        "newly defined methods inside it, and makes it the class of the receiver of instance_eval" do
      true.should == true
    end
    it "should allow us to define methods on the class itself (class methods) - because a class is also an object in ruby" do
      class Hani
        def self.speak
          'hello'
        end
      end
      Hani.speak.should == 'hello'
      Hani.instance_eval do
        def say_goodbye
          'goodbye'
        end
      end
      Hani.say_goodbye.should == 'goodbye'
    end
    it "everytime we call instance_eval on a class, ruby creates an anonymous ghost class and places the "+
        "newly defined methods(class methods) inside it, and makes it the current class of the receiver(which is a class) of instance_eval" do
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
  context 'allows us to create a Domain Specific Language(DSL) in a block' do
    it "should allow us to define and use a DSL inside a block" do
      class Turtle
        def initialize
          @path = []
        end
        def right(n=1)
          @path << "r"*n
        end
        def up(n=1)
          @path << "u"*n
        end
        def path
          @path.join
        end
        def move(&block)
          instance_eval &block
        end
      end
      t = Turtle.new
      t.right(3)
      t.up(2)
      t.right
      t.path.should == 'rrruur'
      t.move do
        right(3)
        up(2)
        right
      end
      t.path.should == 'rrruurrrruur'
    end
  end
end
