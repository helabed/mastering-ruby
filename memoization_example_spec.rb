describe 'memoization examples - many ways to do it - subclassing, method rewriting, delegation' do
  context "example without memoization" do
    class Discounter_0
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end
      def discount(*skus) 
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end
      private
      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation each time" do
      d = Discounter_0.new
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
    end
  end




  context "memoization with a hash" do
    class Discounter_1 
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
        @memory = {}
      end

      def discount(*skus) 
        @expensive_calculation = false
        if @memory.has_key?(skus)
          @memory[skus]
        else
          @memory[skus] = expensive_discount_calculation(*skus)
        end
      end

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once" do
      d = Discounter_1.new
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a subclass" do
    class Discounter_2 
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      def discount(*skus) 
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end                                       

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end

    class MemoDiscounter < Discounter_2
      def initialize
        @memory = {}
      end

      def discount(*skus) 
        @expensive_calculation = false
        if @memory.has_key?(skus)
          @memory[skus]
        else
          @memory[skus] = super
        end
      end
    end
    it "should execute expensive calculation once" do
      d = MemoDiscounter.new
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a subclass with code generation" do
    class Discounter_3 
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      def discount(*skus) 
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end                                       

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end

    def memoize(cls, method)
      Class.new(cls) do
        def initialize
          @memory = {}
        end

        define_method(method) do |*args|
          @expensive_calculation = false
          if @memory.has_key?(args)
            @memory[args]
          else
            @memory[args] = super(*args)
          end
        end
      end
    end
    it "should execute expensive calculation once" do
      d = memoize(Discounter_3, :discount).new
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a subclass with code generation and without adding instance variables(@memory) to the original class - thanks to closure around define_method" do
    class Discounter_31
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      def discount(*skus) 
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end                                       

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end

    def memoize(cls, method)
      Class.new(cls) do
        memory = {}

        # memory is accessible because of the closure around define_method
        # this is better than using @memory because we are not adding a shared state with the original class beign memoized, it is cleaner
        define_method(method) do |*args|
          @expensive_calculation = false
          if memory.has_key?(args)
            memory[args]
          else
            memory[args] = super(*args)
          end
        end
      end
    end
    it "should execute expensive calculation once" do
      d = memoize(Discounter_31, :discount).new
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a ghost class to intercept the call chain in lieu of subclassing whole class" do
    class Discounter_4
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      def discount(*skus) 
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end                                       

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once" do
      d = Discounter_4.new
      def d.discount(*skus)
        @expensive_calculation = false
        @memory ||= {}
        if @memory.has_key?(skus)
          @memory[skus]
        else
          @memory[skus] = super(*skus)
        end
      end
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a ghost class with code generation to create a hidden singleton class" do
    class Discounter_5
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      def discount(*skus) 
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end                                       

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once - see 'create_a_ghost_class_from_an_object.png'" do
      def memoize(obj, method)
        # the line below (obj.class.class_eval do) would fail with 'no superclass method `discount' for #<Discounter_5..' because it is true,
        # we are inside Discounter_5 and it doesn't have a superclass method called discount.
        # so we have to create a ghost class and use class_eval on it - see 'create_a_ghost_class_from_an_object.png'
        # also - see 'create_a_ghost_class_from_an_object_2.png'
        ghost = class << obj
          self
        end
        # now ghost's superclass is Discounter_5 and ghost has superclass method called discount
        ghost.class_eval do
        #obj.class.class_eval do
          memory ||= {}
          define_method(method) do |*args|
            @expensive_calculation = false
            if memory.has_key?(args)
              memory[args]
            else
              memory[args] = super(*args)
            end
          end
        end
      end
      d = Discounter_5.new
      memoize(d, :discount)
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using intrusive method re-writing after opening class" do
    class Discounter_6
      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      def discount(*skus)
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end

      private

      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once" do
      class Discounter_6
        alias_method :_original_discount, :discount
        def discount(*skus)
          @expensive_calculation = false
          @memory ||= {}
          if @memory.has_key?(skus)
            @memory[skus]
          else
            @memory[skus] = _original_discount(*skus)
          end
        end
      end
      d = Discounter_6.new

      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a module to generically do the method re-writing" do
    module Memoize
      def remember(name)
        # try to name our original method in a way(with a space in it) that is illegal to do when it is called by other programmer,
        # however is it fine to define it with a space when it is only being created and called dynamically with send

        # illegal method name in regular Ruby syntax
        original = "_original   _#{name}"

        #original = "_original_#{name}"

        alias_method original, name
        memory ||= {}
        define_method(name) do |*args|
          @expensive_calculation = false
          if memory.has_key?(args)
            memory[args]
          else
            memory[args] = send(original,*args)
          end
        end
      end
    end
    class Discounter_7
      extend Memoize

      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end
      def discount(*skus)
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end

      remember :discount

      private
      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once" do
      d = Discounter_7.new

      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a module and bind to generically do the method re-writing" do
    module Memoize
      def remember(name)
        # memoization with help of method binding was invented by Robert Felt

        # converting a method into an object  with help of Ruby's native "instance_method" method
        original_method = instance_method(name)

        # no need for alias_method anymore
        #alias_method original, name

        memory ||= {}
        define_method(name) do |*args|
          @expensive_calculation = false
          if memory.has_key?(args)
            memory[args]
          else
            bound_method = original_method.bind(self)
            memory[args] = bound_method.call(*args)
            #memory[args] = send(original,*args)
          end
        end
      end
    end
    class Discounter_8
      extend Memoize

      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end
      def discount(*skus)
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end

      remember :discount

      private
      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once" do
      d = Discounter_8.new

      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using a module and a DSL to generically do the method re-writing" do
    module Memoize
      def remember(name, &block)
        # memoization with help of method binding was invented by Robert Felt

        # to define the original method from the passed in block
        define_method(name, &block)

        # converting a method into an object  with help of Ruby's native "instance_method" method
        original_method = instance_method(name)

        # no need for alias_method anymore
        #alias_method original, name

        memory ||= {}
        define_method(name) do |*args|
          @expensive_calculation = false
          if memory.has_key?(args)
            memory[args]
          else
            bound_method = original_method.bind(self)
            memory[args] = bound_method.call(*args)
            #memory[args] = send(original,*args)
          end
        end
      end
    end
    class Discounter_9
      extend Memoize

      # we are explicitly calling the memoize method 'remember' using a mini DSL
      remember :discount do |*skus|
        @expensive_calculation = false
        expensive_discount_calculation(*skus)
      end

      attr_accessor :expensive_calculation
      def initialize
        @expensive_calculation = false
      end

      private
      def expensive_discount_calculation(*skus)
        @expensive_calculation = true
        skus.inject {|m,n| m + n }
      end
    end
    it "should execute expensive calculation once" do
      d = Discounter_9.new

      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == true
      d.discount(1,2,3).should == 6
      d.expensive_calculation.should == false
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == true
      d.discount(2,3,4).should == 9
      d.expensive_calculation.should == false
    end
  end




  context "memoization using Delegation" do
    it "should execute expensive calculation once" do
      pending
    end
  end
end




