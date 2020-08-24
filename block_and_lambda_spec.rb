RSpec.describe 'blocks, Procs and lambdas.' do
  context 'many ways to define/create an object out of a block.' do
    it 'can be created with a lambda' do
      l = lambda { |a| a+1 }
      expect(l.call(99)).to eq(100)
    end
    it 'can be created with Proc.new' do
      l = Proc.new { |a| a+1 }
      expect(l.call(99)).to eq(100)
    end
    it "can be created when passed as a method parameter with an '&' prepended - internally same as Proc.new" do
      def convert(&block)
        block
      end
      l = convert { |a| a+1 }
      expect(l.call(99)).to eq(100)
    end
    context 'and a deprecated way to do it, is same as lambda in Ruby 1.8, and Proc.new in Ruby 1.9' do
      it "can be created with a with a call to the built in method 'proc' - avoid using 'proc'" do
        l = proc { |a| a+1 }
        expect(l.call(99)).to eq(100)
      end
    end
    it 'can be created with the stabby proc operator -> and called just like Proc.new.call is called' do
      stabby = -> (a) { a+1 }
      expect(stabby.call(99)).to eq(100)
    end
    it 'can be created with the stabby proc operator -> and called using the square bracket syntax' do
      stabby = -> (a) { a+1 }
      expect(stabby[99]).to eq(100)
    end
  end
  context "Proc.new is liberal in dealing with parameters passing - behaves like parallel assignemnt." do
    it 'runs fine when passed the exact number of arguments as it was defined' do
      l = Proc.new { |a,b,c| a+b+c }
      expect(l.call(1,2,3)).to eq(6)
    end
    it 'runs fine when passed the exact number of string arguments as it was defined' do
      l = Proc.new { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      expect(l.call('1','2','3','4')).to eq('1234')
    end
    it 'runs fine when passed a smaller number of arguments as it was defined' do
      l = Proc.new { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      expect(l.call('1','2')).to eq('12')
    end
    it 'runs fine when passed a larger number of arguments as it was defined' do
      l = Proc.new { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      expect(l.call('1','2','3','4','5')).to eq('1234')
    end
    it 'runs fine when passed a larger number of arguments and when it is defined with a variable argument list' do
      l = Proc.new { |a,b,c,*d| "#{a}#{b}#{c}#{d.join}" }
      expect(l.call('1','2','3','4','5')).to eq('12345')
    end
  end

  context "lambda is restrictive in dealing with parameters passing - behaves like a method call." do
    it 'runs fine when passed the exact number of arguments as it was defined' do
      l = lambda { |a,b,c| a+b+c }
      expect(l.call(1,2,3)).to eq(6)
    end
    it 'runs fine when passed the exact number of string arguments as it was defined' do
      l = lambda { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      expect(l.call('1','2','3','4')).to eq('1234')
    end
    it 'raises an error when passed a smaller number of arguments as it was defined' do
      l = lambda { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      expect{ l.call('1','2') }.to raise_error(ArgumentError, "wrong number of arguments (given 2, expected 4)")
    end
    it 'raises an error when passed a larger number of arguments as it was defined' do
      l = lambda { |a,b,c,d| "#{a}#{b}#{c}#{d}" }
      expect{ l.call('1','2','3','4','5') }.to raise_error(ArgumentError, "wrong number of arguments (given 5, expected 4)")
    end
    it 'runs fine when passed a larger number of arguments and when it is defined with a variable argument list' do
      l = lambda { |a,b,c,*d| "#{a}#{b}#{c}#{d.join}" }
      expect(l.call('1','2','3','4','5')).to eq('12345')
    end
  end

  context "a 'return' statement from Proc.new exists the surrounding context - behaves like inline code." do
    it 'should exit surrounding method and should not reach bottom of said method' do
      @bottom_of_method_a_reached = false
      def method_a
        l = Proc.new { return }
        l.call
        @bottom_of_method_a_reached = true
      end
      method_a
      expect(@bottom_of_method_a_reached).to eq(false)
    end

    context 'because a block passed to a method such as collection.each is always converted to a Proc.new' do
      it "should exit the surrounding  method as expected when code inside a block hits a return statement" do
        @bottom_of_method_c_reached = false
        def method_c
          [1,2,3].each do |val|
            return if val > 2
          end
          @bottom_of_method_c_reached = true
        end
        method_c
        expect(@bottom_of_method_c_reached).to eq(false)
      end
    end
  end

  context "a 'return' statement from lambda exists the proc only - lambda behaves like a method." do
    it 'should exit the block only and execution should reach bottom of surrounding method' do
      @bottom_of_method_b_reached = false
      def method_b
        l = lambda { return }
        l.call
        @bottom_of_method_b_reached = true
      end
      method_b
      expect(@bottom_of_method_b_reached).to eq(true)
    end
  end

  context "a 'binding' is the context in which code is executing." do
    before(:all) do
      class Simple
        attr_accessor :ivar
        def initialize
          @ivar = "an instance var"
        end
        def get_var(var)
          var
        end
        def give_me_the_binding(param)
          var = "some local var"
          get_var(var)
          binding     # a kernel method
        end
      end
    end
    it 'should provide access to all variables in this binding including all passed parameters, instance variables, and local variables' do
      s = Simple.new
      @the_binding = s.give_me_the_binding(99) { "block value" }
      expect(eval('param',@the_binding)).to eq(99)
      expect(eval('var',@the_binding)).to eq('some local var')
      expect(eval('@ivar',@the_binding)).to eq(s.ivar)
      expect(eval('@ivar',@the_binding)).to eq('an instance var')
    end
    it 'should provide access to all associated block in this binding' do
      s = Simple.new
      @the_binding = s.give_me_the_binding(99) { "block value" }
      expect(eval('yield',@the_binding)).to eq('block value')
    end
    it "should provide access to 'self' in this binding" do
      s = Simple.new
      @the_binding = s.give_me_the_binding(99) { "block value" }
      expect(eval('self',@the_binding)).to eq(s)
    end
    it "Ruby provides a binding with every block it creates when using 'lambda'" do
      def n_times(n)
        lambda {|val| n * val }
      end

      two_times = n_times(2)
      expect(two_times.call(3)).to eq(6)
      expect(eval('n', two_times.binding)).to eq(2)
    end
    it "Ruby provides a binding with every block it creates when using 'Proc.new'" do
      def many_times(n)
        Proc.new {|val| n * val }
      end

      three_times = many_times(3)
      expect(three_times.call(5)).to eq(15)
      expect(eval('n', three_times.binding)).to eq(3)
    end
  end
  context "a 'reference' to the block can be passed around with an '&'" do
    class A
      attr_accessor :a, :b
      def initialize(a, &b)
         @a = a
         @b = b
      end
    end
    c = 0
    a = A.new(1) { c = 2 }
    it "then the block can be called with the call method" do
      a.b.call
      expect(c).to eq(2)
    end
  end
end

