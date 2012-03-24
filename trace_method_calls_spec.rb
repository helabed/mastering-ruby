describe 'trace method calls' do
  context 'first iteration' do
    it "should trace a simple method everytime it is called with the help of define_method with block in Ruby 1.9" do
      module TraceMethodCalls_1
        def self.included(klass)
          def klass.method_added(name)
            #puts "inside method_added for #{name}, but outside define_method self is: #{self.inspect}"
            return if @_adding_a_method
            @_adding_a_method = true
            original_method = "original #{name}"
            alias_method original_method, name
            define_method(name) do |*args, &block|
              #puts "inside method_added, and inside define_method self is: #{self.inspect}"
              self.class.queue << "Calling method #{name} with #{args.inspect}"
              result = send original_method, *args, &block
              self.class.queue << "result = #{result}"
              #puts "leaving method_added for #{name}, and self is: #{self.inspect}"
              result
            end
            @_adding_a_method = false
          end
        end
      end
      class Example_1
        include TraceMethodCalls_1

        class << self
          attr_accessor :queue
        end
        @queue = []

        def a_method( arg1, arg2 )
          arg1 + arg2
        end

        def another_method( arg1 )
          arg1 * yield
        end

        def empty_method

        end
      end
      ex = Example_1.new
      ex.a_method(3,4)
      Example_1.queue.shift.should == "Calling method a_method with [3, 4]"
      Example_1.queue.shift.should == "result = 7"
      ex.another_method(50) { 2 }
      Example_1.queue.shift.should == "Calling method another_method with [50]"
      Example_1.queue.shift.should == "result = 100"
      ex.empty_method
      Example_1.queue.shift.should == "Calling method empty_method with []"
      Example_1.queue.shift.should == "result = "
    end
    it "should trace a simple method everytime it is called with the help of class_eval and without define_method so that it can work with Ruby 1.8" do
      module TraceMethodCalls_2
        def self.included(klass)
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_2.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.wrap_method(klass, name)
          original_method = "original_#{name}"
          body = %{
            alias_method :#{original_method}, :#{name}
            def #{name}(*args, &block)
              self.class.queue << "Calling method #{name} with \#{args.inspect}"
              result = #{original_method}(*args, &block)
              self.class.queue << "result = \#{result}"
              result
            end
          }
          puts body
          klass.class_eval body
        end
      end
      class Example_2
        include TraceMethodCalls_2

        class << self
          attr_accessor :queue
        end
        @queue = []

        def a_method( arg1, arg2 )
          arg1 + arg2
        end

        def another_method( arg1 )
          arg1 * yield
        end

        def empty_method

        end
      end
      ex = Example_2.new
      ex.a_method(3,4)
      Example_2.queue.shift.should == "Calling method a_method with [3, 4]"
      Example_2.queue.shift.should == "result = 7"
      ex.another_method(50) { 2 }
      Example_2.queue.shift.should == "Calling method another_method with [50]"
      Example_2.queue.shift.should == "result = 100"
      ex.empty_method
      Example_2.queue.shift.should == "Calling method empty_method with []"
      Example_2.queue.shift.should == "result = "
    end
  end
end

