describe 'class_eval or module_eval' do
  context 'allows us to execute any code inside a block where the receiver is a class or a module' do
    it "should execte any code where the receiver is a class" do
      expect(
        String.class_eval do
          self
        end
      ).to eq(String)
    end
    it "should execte any code where the receiver is a module" do
      module MyModule
      end
      expect(
        MyModule.class_eval do
          self
        end
      ).to eq(MyModule)
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

      expect(my_string.as_a_cat).to eq 'kitty says: Hello people'
      # or any other string object
      expect("miaow".as_a_cat).to  eq 'kitty says: miaow'
    end
    it "everytime we call class_eval on a class, ruby places the "+
        "newly defined methods(instance methods) inside it, and makes it the current class of the receiver of class_eval" do
      expect(true).to eq(true)
    end
    it "class_eval would declare instance methods, because class_eval can be called only on classes and modules in ruby - the name reflects the receiver" do
      expect(true).to eq(true)
    end
    it "instance_eval would declare class methods, because instance_eval can be called on every single object in ruby - the name reflects the receiver" do
      expect(true).to eq(true)
    end
    it "see file 'receiver_a_class__class_eval__creates_instance_methods.png' to find out what the 'def' method does inside class_eval" do
      expect(true).to eq(true)
    end
    it "see file 'receiver_a_class__instance_eval__creates_class_methods.png' to find out what the 'def' method does inside instance_eval" do
      expect(true).to eq(true)
    end
    it "see file 'receiver__xxx_eval__truth_table.png' to find out what the 'def' method does for all cases" do
      expect(true).to eq(true)
    end
  end
  context 'allows us to define methods or code inside a class given a class object' do
    it "should allow us to define instance methods on the class itself" do
      module Hello
        def say_hello
          "Hi from: #{self.inspect} - I am a #{self.class}"
        end
      end

      [String, Array, Hash].each do |cls|
        cls.class_eval { include Hello }
      end

      expect("miaow".say_hello).to eq 'Hi from: "miaow" - I am a String'
      expect([1,2,3].say_hello).to eq 'Hi from: [1, 2, 3] - I am a Array'
      expect({:key => 'value'}.say_hello).to eq 'Hi from: {:key=>"value"} - I am a Hash'
    end
  end
end
