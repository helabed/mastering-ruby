describe 'Modulization' do
  context "for namespacing constants and classes" do
    module Math
      ALMOST_PI = 22.0/7

      class Calculator
      end
    end

    it "should provide access to the module's constant" do
      Math::ALMOST_PI.should == 22.0/7
    end
    it "should provide access to the module's class" do
      Math::Calculator.new.class.should == Math::Calculator
    end
  end

  context "for defining and finding module methods with namespaces" do
    module Math
      def self.is_even?(num)
        (num & 1) == 0
      end
    end

    it "should provide access to the module's methods" do
      Math.is_even?(1).should == false
      Math.is_even?(2).should == true
    end
  end

  context "for creating instance methods" do
    module Logger
      def log(msg)
        msg
      end
    end

    class Truck
      include Logger
    end

    it "should provide access to the module's instance method" do
      a_truck = Truck.new
      a_truck.log("hello").should == "hello"
    end

    it "should assert that to 'include' a module's instance method does not mean copying the method's body, but instead referencing the one and only copy of it" do
      a_truck = Truck.new
      # reopening and overwriting log method
      module Logger
        def log(msg)
          "go away"
        end
      end
      a_truck.log("hello").should == "go away"
    end

    it "should be available for use from more than one class" do
      module Logger
        def log(msg)
          msg
        end
      end

      class Ship
        include Logger
      end

      a_truck = Truck.new
      a_truck.log("in Truck").should == "in Truck"
      a_ship = Ship.new
      a_ship.log("in Ship").should == "in Ship"
    end

    it "should be available for use from an object with the 'extend' keyword" do
      module Logger
        def log(msg)
          msg
        end
      end

      animal = "cat"
      animal.extend Logger
      animal.log("Greetings from the cat").should == "Greetings from the cat"
    end

    it "should be available for use from an object by including the methods from the module into a singleton class using 'class << object' " do
      module Logger
        def log(msg)
          msg
        end
      end

      animal = "cat"
      class << animal
        include Logger
      end
      animal.log("Greetings from the singleton cat").should == "Greetings from the singleton cat"
    end
  end

  context "for converting a module instance methods into class methods of the class that is mixing in the module" do
    module Logger
      def log(msg)
        msg
      end
    end

    class Truck
      class << self
        include Logger
      end
    end

    it "should provide access to the module's instance method as a class method using a singleton class using 'class << self' " do
      Truck.log("hello from the Truck class").should == "hello from the Truck class"
    end

    it "should provide access to the module's instance method as a class method using the 'extend' keyword" do

      class Car
        extend Logger
        #class << self
        #  include Logger
        #end
      end

      Car.log("hello from the Car class").should == "hello from the Car class"
    end
  end

  context "for inheritance without subclassing" do
    module Persistable
      module ClassMethods
        def find
          "In find"
          new
        end
      end

      def save
        "In save"
      end
    end

    context "with include and extend keywords" do
      class Person
        include Persistable
        extend Persistable::ClassMethods
      end

      context "must provide access to class methods and instance methods of the module" do
        it "should provide access to class methods" do
          p = Person.find
          p.class.should == Person
        end
        it "should provide access to instance methods" do
          p = Person.find
          p.save.should == 'In save'
        end
      end
    end

    context "with include only keywords, and with help of self.included(the_class) ruby hook" do
      module Persistable
        def self.included(cls)
          cls.extend ClassMethods
        end
      end
      class Person
        include Persistable
        #extend Persistable::ClassMethods  # removed because now using the self.included(cls) hook method
      end

      context "must provide access to class methods and instance methods of the module" do
        it "should provide access to class methods" do
          p = Person.find
          p.class.should == Person
        end
        it "should provide access to instance methods" do
          p = Person.find
          p.save.should == 'In save'
        end
      end
    end
  end
  context "using alias method chain to override a method in a class that includes a module" do
    module M
      def test_method
        "Test from M"
      end

      def test_method_from_m
        "Test from M"
      end
    end

    class C
      def test_method
        "Test from C"
      end
    end
    context "without calling alias_method" do
      it "does not work as intended because any included modules are searched for methods after the class's own methods" +
           " are searched, so you cannot directly overwrite a class's method by including a module" do
        C.send(:include, M)
        C.new.test_method.should == "Test from C"
      end
    end
    context "with a call to alias_method" do
      it "works as intended in that they allow us to overwrite a class's method by including a module and using a different method name" do
        C.send(:include, M)
        C.class_eval do
          alias_method  :test_method_from_c, :test_method
          alias_method  :test_method, :test_method_from_m
        end
        C.new.test_method.should == "Test from M"
      end
    end
  end

end
