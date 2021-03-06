describe 'instance_eval' do
  context 'allows us to execute any code inside a block - unlike eval' do
    it "should execte any code" do
      result = instance_eval do
        'hello'
      end
      expect(result).to eq 'hello'
    end
    it "should execte any code with a receiver - unlike eval which is a private method" do
      result = "cat".instance_eval do
        self
      end
      expect(result).to eq 'cat'
    end
    it "inside the block of the receiver 'self' is set to the receiver of instance_eval" do
      result = "cat".instance_eval do
        upcase
      end
      expect(result).to eq 'CAT'
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
        expect {@m.the_var}.to raise_error(NoMethodError)
      end
      it "with instance_eval we should be able to access the instance variable (both read/write)" do
        result = @m.instance_eval do
          @the_var
        end
        expect(result).to eq 66
        result2 = @m.instance_eval do
          @the_var = 'the_cat'
          @the_var
        end
        expect(result2).to eq 'the_cat'
      end
      it "without instance_eval we should not be able to access private methods" do
        expect {@m.secret}.to raise_error(NoMethodError)
      end
      it "with instance_eval we should be able to access private methods - i.e methods without a receiver" do
        result = @m.instance_eval do
          secret
        end
        expect(result).to eq 'my private secret'
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
        expect {obj.method1(@m)}.to raise_error(NameError)
        expect(obj.method3(@m)).to eq 55
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
      expect(animal.speak).to eq 'miaow'
    end
    it "everytime we call instance_eval on an object, ruby creates an anonymous ghost class and places the "+
        "newly defined methods inside it, and makes it the class of the receiver of instance_eval" do
      expect(true).to eq true
    end
    it "should allow us to define methods on the class itself (class methods) - because a class is also an object in ruby" do
      class Hani
        def self.speak
          'hello'
        end
      end
      expect(Hani.speak).to eq 'hello'
      Hani.instance_eval do
        def say_goodbye
          'goodbye'
        end
      end
      expect(Hani.say_goodbye).to eq 'goodbye'
    end
    it "everytime we call instance_eval on a class, ruby creates an anonymous ghost class and places the "+
        "newly defined methods(class methods) inside it, and makes it the current class of the receiver(which is a class) of instance_eval" do
      expect(true).to eq true
    end
    it "class_eval would declare instance methods, because class_eval can be called only on classes and modules in ruby - the name reflects the receiver" do
      expect(true).to eq true
    end
    it "instance_eval would declare class methods, because instance_eval can be called on every single object in ruby - the name reflects the receiver" do
      expect(true).to eq true
    end
    it "see file 'receiver_a_class__class_eval__creates_instance_methods.png' to find out what the 'def' method does inside class_eval" do
      expect(true).to eq true
    end
    it "see file 'receiver_a_class__instance_eval__creates_class_methods.png' to find out what the 'def' method does inside instance_eval" do
      expect(true).to eq true
    end
    it "see file 'receiver__xxx_eval__truth_table.png' to find out what the 'def' method does for all cases" do
      expect(true).to eq true
    end
  end
  context 'allows us to create a Domain Specific Language(DSL) in a block' do
    it "should allow us to define and use a DSL inside a block - though people are moving away from such implementation because of wrong assumption that we have a closure around the block" do
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
        def bad_move
          # this does not work because the { } block will be run in this 'self' object context
          # but the yield will be run in the original context where right, and up are not defined
          instance_eval { yield }
        end
        def move(&block)
          # this 'block' will be executed in the context of this 'self'
          instance_eval &block
        end
      end
      t = Turtle.new
      t.right(3)
      t.up(2)
      t.right
      expect(t.path).to eq 'rrruur'

      t.move do
        right(3)
        up(2)
        right
      end
      expect(t.path).to eq 'rrruurrrruur'

      expect {
      t.bad_move do
        right(3)
        up(2)
        right
      end
      }.to raise_error(NoMethodError)

      # @count below is defined in this context but not inside the to object 't' itself
      # so even though it looks like @count should be available inside the block. But remember,
      # we do NOT have a closure with instance_eval blocks, we are changing self to the receiver 't' where @count does
      # not exist.
      expect {
        @count = 3
        t.move do
          right(@count)
          up(2)
          right
        end
      }.to raise_error(TypeError)
    end
  end
end
