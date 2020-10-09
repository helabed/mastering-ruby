describe 'Modulization' do
  context "for namespacing constants and classes" do
    module Math
      ALMOST_PI = 22.0/7

      class Calculator
      end
    end

    it "should provide access to the module's constant" do
      expect(Math::ALMOST_PI).to eq 22.0/7
    end
    it "should provide access to the module's class" do
      expect(Math::Calculator.new.class).to eq Math::Calculator
    end
  end

  context "for defining and finding module methods with namespaces" do
    module Math
      def self.is_even?(num)
        (num & 1) == 0
      end
    end

    it "should provide access to the module's methods" do
      expect(Math.is_even?(1)).to eq false
      expect(Math.is_even?(2)).to eq true
    end
  end

  context "for creating instance methods" do
    module MyLogger
      def log(msg)
        msg
      end
    end

    class Truck
      include MyLogger
    end

    it "should provide access to the module's instance method" do
      a_truck = Truck.new
      expect(a_truck.log("hello")).to eq "hello"
    end

    it "should assert that to 'include' a module's instance method does not mean copying the method's body, but instead referencing the one and only copy of it" do
      a_truck = Truck.new
      # reopening and overwriting log method
      module MyLogger
        def log(msg)
          "go away"
        end
      end
      expect(a_truck.log("hello")).to eq "go away"
    end

    it "should be available for use from more than one class" do
      module MyLogger
        def log(msg)
          msg
        end
      end

      class Ship
        include MyLogger
      end

      a_truck = Truck.new
      expect(a_truck.log("in Truck")).to eq "in Truck"
      a_ship = Ship.new
      expect(a_ship.log("in Ship")).to eq "in Ship"
    end

    it "should be available for use from an object with the 'extend' keyword" do
      module MyLogger
        def log(msg)
          msg
        end
      end

      animal = "cat"
      animal.extend MyLogger
      expect(animal.log("Greetings from the cat")).to eq "Greetings from the cat"
    end

    it "should be available for use from an object by including the methods from the module into a singleton class using 'class << object' " do
      module MyLogger
        def log(msg)
          msg
        end
      end

      animal = "cat"
      class << animal
        include MyLogger
      end
      expect(animal.log("Greetings from the singleton cat")).to eq "Greetings from the singleton cat"
    end
  end

  context "for converting a module instance methods into class methods of the class that is mixing in the module" do
    module MyLogger
      def log(msg)
        msg
      end
    end

    class Truck
      class << self
        include MyLogger
      end
    end

    it "should provide access to the module's instance method as a class method using a singleton class using 'class << self' " do
      expect(Truck.log("hello from the Truck class")).to eq "hello from the Truck class"
    end

    it "should provide access to the module's instance method as a class method using the 'extend' keyword" do

      class Car
        extend MyLogger
      end

      expect(Car.log("hello from the Car class")).to eq "hello from the Car class"
    end

    it "should provide access to the module's instance method as a class method using the 'extend' keyword and from within the extending class at the class level" do

      class Accessor
        extend MyLogger

        class << self
          attr_accessor :the_message
        end

        @the_message = log("hello from inside the Accessor class")
        # to avoid using '*.should == *' below (should is deprecated), had to set the_message as
        # a class level instance variable. RSpec 3 'expect' was not visible from within Accessor
        #log("hello from inside the Accessor class").should == "hello from inside the Accessor class"
      end
      expect(Accessor.the_message).to eq "hello from inside the Accessor class"
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
          expect(p.class).to eq Person
        end
        it "should provide access to instance methods" do
          p = Person.find
          expect(p.save).to eq 'In save'
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
          expect(p.class).to eq Person
        end
        it "should provide access to instance methods" do
          p = Person.find
          expect(p.save).to eq 'In save'
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
        expect(C.new.test_method).to eq "Test from C"
      end
    end
    context "with a call to alias_method" do
      it "works as intended in that they allow us to overwrite a class's method by including a module and using a different method name" do
        C.send(:include, M)
        C.class_eval do
          alias_method  :test_method_from_c, :test_method
          alias_method  :test_method, :test_method_from_m
        end
        expect(C.new.test_method).to eq "Test from M"
      end
    end
  end
end
