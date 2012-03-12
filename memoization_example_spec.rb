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
        # we are inside Discounter_5 and it doesn't have a superclass
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
end




