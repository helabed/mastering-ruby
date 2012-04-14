describe 'blocks, Procs and lambdas.' do
  context 'many ways to define/create an object out of a block.' do
    it 'can be created with a lambda' do
      l = lambda { |a| a+1 }
      l.call(99).should == 100
    end
    it 'can be created with Proc.new' do
      l = Proc.new { |a| a+1 }
      l.call(99).should == 100
    end
    it "can be created when passed as a method parameter with an '&' prepended - internally same as Proc.new" do
      def convert(&block)
        block
      end
      l = convert { |a| a+1 }
      l.call(99).should == 100
    end
    context 'and a deprecated way to do it, is same as lambda in Ruby 1.8, and Proc.new in Ruby 1.9' do
      it "can be created with a with a call to the built in method 'proc' - so avoid it" do
        l = proc { |a| a+1 }
        l.call(99).should == 100
      end
    end
  end
  context "Proc.new is liberal in dealing with parameters passing - behaves like parallel assignemnt." do
    it 'runs fine when passed the exact number of arguments as it was defined' do
      l = Proc.new { |a,b,c| a+b+c }
      l.call(1,2,3).should == 6
    end
    it 'runs fine when passed the exact number of string arguments as it was defined' do
      l = Proc.new { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      l.call('1','2','3','4').should == '1234'
    end
    it 'runs fine when passed a smaller number of arguments as it was defined' do
      l = Proc.new { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      l.call('1','2').should == '12'
    end
    it 'runs fine when passed a larger number of arguments as it was defined' do
      l = Proc.new { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      l.call('1','2','3','4','5').should == '1234'
    end
    it 'runs fine when passed a larger number of arguments and when it is defined with a variable argument list' do
      l = Proc.new { |a,b,c,*d| "#{a}#{b}#{c}#{d.join}" }
      l.call('1','2','3','4','5').should == '12345'
    end
  end

  context "lambda is restrictive in dealing with parameters passing - behaves like a method call." do
    it 'runs fine when passed the exact number of arguments as it was defined' do
      l = lambda { |a,b,c| a+b+c }
      l.call(1,2,3).should == 6
    end
    it 'runs fine when passed the exact number of string arguments as it was defined' do
      l = lambda { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      l.call('1','2','3','4').should == '1234'
    end
    it 'raises an error when passed a smaller number of arguments as it was defined' do
      l = lambda { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      lambda {
        l.call('1','2')}.should raise_error(ArgumentError, "wrong number of arguments (2 for 4)")
    end
    it 'raises an error when passed a larger number of arguments as it was defined' do
      l = lambda { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      lambda {
        l.call('1','2','3','4','5')}.should raise_error(ArgumentError, "wrong number of arguments (5 for 4)")
    end
    it 'runs fine when passed a larger number of arguments and when it is defined with a variable argument list' do
      l = lambda { |a,b,c,*d| "#{a}#{b}#{c}#{d.join}" }
      l.call('1','2','3','4','5').should == '12345'
    end
  end

  context "a 'return' statement from Proc.new exists the surrounding context - behaves like inline code." do
    it 'should exit surrounding method and should not reach bottom of method' do
      @bottom_of_method_a_reached = false
      def method_a
        l = Proc.new { return }
        l.call
        @bottom_of_method_a_reached = true
      end
      method_a
      @bottom_of_method_a_reached.should == false
    end

    it "should exit the method as expected when code inside a block hits a return statement" do
      # because a block passed to a method such as collection.each is always converted to a Proc.new automatically
      @bottom_of_method_c_reached = false
      def method_c
        [1,2,3].each do |val|
          return if val > 2
        end
        @bottom_of_method_c_reached = true
      end
      method_c
      @bottom_of_method_c_reached.should == false
    end
  end

  context "a 'return' statement from lambda exists the proc only - behaves like a method." do
    it 'should exit the block only and should reach bottom of method' do
      @bottom_of_method_b_reached = false
      def method_b
        l = lambda { return }
        l.call
        @bottom_of_method_b_reached = true
      end
      method_b
      @bottom_of_method_b_reached.should == true
    end
  end

  context "a 'binding' is the context in which code is executing." do
    before(:all) do
      class Simple
        attr_accessor :ivar
        def initialize
          @ivar = "I am alive"
        end
        def give_me_the_binding(param)
          var = "some variable"
          binding     # a kernel method
        end
      end
    end
    it 'should provide access to all variables in this binding including all passed parameters, instance variables, and local variables' do
      s = Simple.new
      @the_binding = s.give_me_the_binding(99) { "block value" }
      eval('param',@the_binding).should == 99
      eval('var',@the_binding).should == 'some variable'
      eval('@ivar',@the_binding).should == s.ivar
      eval('@ivar',@the_binding).should == 'I am alive'
    end
    it 'should provide access to all associated block in this binding' do
      s = Simple.new
      @the_binding = s.give_me_the_binding(99) { "block value" }
      eval('yield',@the_binding).should == 'block value'
    end
    it "should provide access to 'self' in this binding" do
      s = Simple.new
      @the_binding = s.give_me_the_binding(99) { "block value" }
      eval('self',@the_binding).should == s
    end
    it "Ruby provides a binding with every block it creates - with lambda" do
      def n_times(n)
        lambda {|val| n * val }
          # Proc.new also works the same way (below)
        #Proc.new {|val| n * val }
      end

      two_times = n_times(2)
      two_times.call(3).should == 6
      eval('n', two_times.binding).should == 2
    end
    it "Ruby provides a binding with every block it creates - with Proc.new" do
      def many_times(n)
        Proc.new {|val| n * val }
      end

      three_times = many_times(3)
      three_times.call(5).should == 15
      eval('n', three_times.binding).should == 3
    end
  end
end
