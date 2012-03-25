describe 'trace method calls' do
  context '- first iteration' do
    it "should trace a simple method everytime it is called with the help of define_method with block in Ruby 1.9" do
      module TraceMethodCalls_1
        def self.included(klass)
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            #puts "inside method_added for #{name}, but outside define_method self is: #{self.inspect}"
            return if @_adding_a_method
            @_adding_a_method = true
            original_method = "original #{name}"
            alias_method original_method, name
            # inside here, we are overwriting the method name with our own tracing method
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
  end
  context '- second iteration' do
    it "should trace a simple method everytime it is called with the help of class_eval and without define_method so that it can work with Ruby 1.8" do
      module TraceMethodCalls_2
        def self.included(klass)
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_2.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.wrap_method(klass, name)
          original_method = "original_#{name}"
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            alias_method :#{original_method}, :#{name}
            def #{name}(*args, &block)
              self.class.queue << "Calling method #{name} with \#{args.inspect}"
              result = #{original_method}(*args, &block)
              self.class.queue << "result = \#{result}"
              result
            end
          }
          #puts body
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
  context '- third iteration' do
    it "should trace simple and complex methods(<<,[], and variable=) everytime it is called with the help of instance_method and Ruby 1.9" do
      module TraceMethodCalls_3
        def self.included(klass)
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            #puts "inside klass.method_added, self is: #{self.inspect}, and name is: #{name}"
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_3.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.wrap_method(klass, name)
          #puts "inside wrap_method, self is: #{self.inspect} and name is: #{name}"
          klass.class_eval do
            #puts "inside klass.class_eval, self is: #{self.inspect}, and name is: #{name}"
            original_method = instance_method(name)
            # inside here, we are overwriting the method name with our own tracing method
            define_method(name) do |*args, &block|
              #puts "inside klass.class_eval, and inside define_method self is: #{self.inspect}"
              self.class.queue << "Calling method #{name} with #{args.inspect}"
              original = original_method.bind(self)
              result = original.call(*args, &block)
              self.class.queue << "result = #{result}"
              #puts "leaving define_method for #{name}, and self is: #{self.inspect}"
              result
            end
          end
        end
      end
      class Example_3
        include TraceMethodCalls_3

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

        def name=(name)
          @name = name
        end

        def <<(thing)
          "pushing #{thing}"
        end
      end
      ex = Example_3.new
      ex.a_method(3,4)
      Example_3.queue.shift.should == "Calling method a_method with [3, 4]"
      Example_3.queue.shift.should == "result = 7"
      ex.another_method(50) { 2 }
      Example_3.queue.shift.should == "Calling method another_method with [50]"
      Example_3.queue.shift.should == "result = 100"
      ex.name = 'fred'
      Example_3.queue.shift.should == "Calling method name= with [\"fred\"]"
      Example_3.queue.shift.should == "result = fred"
      ex << 'cat'
      Example_3.queue.shift.should == "Calling method << with [\"cat\"]"
      Example_3.queue.shift.should == "result = pushing cat"
    end
  end
  context '- sidenote - prove that a CONST is available from within both a Ruby class and its instance' do
    class MyClass
      MY_CONST = {:my_var => 'var_1'}
    end

    it "should have access to the CONST at the class level" do
      MyClass::MY_CONST[:my_var].should == 'var_1'
    end

    it "should have access to the CONST from any instance of the class" do
      my_class = MyClass.new
      # one way of getting at the constant
      my_class.class.const_get(:MY_CONST)[:my_var].should == 'var_1'
      # another way of getting at the constant
      my_class.class::MY_CONST[:my_var].should == 'var_1'
      # yet another way of getting at the constant
      my_class.instance_eval {MY_CONST[:my_var]}.should == 'var_1'
    end
  end
  context '- forth iteration' do
    it "should trace simple and complex methods(<<,[], and variable=) everytime it is called with the help of instance_method and Ruby 1.8 and METHOD_HASH" do
      module TraceMethodCalls_4
        def self.included(klass)
          method_hash = klass.const_set(:METHOD_HASH, {})
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_4.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.wrap_method(klass, name)
          method_hash = klass.const_get(:METHOD_HASH)
          method_hash[name] = klass.instance_method(name)
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            def #{name}(*args, &block)
              self.class.queue << "Calling method #{name} with \#{args.inspect}"
              result = METHOD_HASH[:#{name}].bind(self).call(*args, &block)
              self.class.queue << "result = \#{result}"
              result
            end
          }
          #puts body
          klass.class_eval body
        end
      end
      class Example_4
        include TraceMethodCalls_4

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

        def name=(name)
          @name = name
        end

        def <<(thing)
          "pushing #{thing}"
        end
      end
      ex = Example_4.new
      ex.a_method(3,4)
      Example_4.queue.shift.should == "Calling method a_method with [3, 4]"
      Example_4.queue.shift.should == "result = 7"
      ex.another_method(50) { 2 }
      Example_4.queue.shift.should == "Calling method another_method with [50]"
      Example_4.queue.shift.should == "result = 100"
      ex.empty_method
      Example_4.queue.shift.should == "Calling method empty_method with []"
      Example_4.queue.shift.should == "result = "
      ex.name = 'fred'
      Example_4.queue.shift.should == "Calling method name= with [\"fred\"]"
      Example_4.queue.shift.should == "result = fred"
      ex << 'cat'
      Example_4.queue.shift.should == "Calling method << with [\"cat\"]"
      Example_4.queue.shift.should == "result = pushing cat"
    end
  end
  context '- fifth iteration' do
    it "should trace any existing class in Ruby 1.8 - try it with Time class" do
      module TraceMethodCalls_5
        def self.included(klass)
          method_hash = klass.const_set(:METHOD_HASH, {})
          # instance_methods(false) because we don't want inherited methods
          klass.instance_methods(false).sort.each do |meth|
            # meth is provided as a string and not a symbol ( a total inconsistency in Ruby)
            wrap_method(klass, meth.to_sym)
          end
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_5.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.wrap_method(klass, name)
          method_hash = klass.const_get(:METHOD_HASH)
          method_hash[name] = klass.instance_method(name)
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            def #{name}(*args, &block)
              self.class.queue << "Calling method #{name} with \#{args.inspect}"
              result = METHOD_HASH[:#{name}].bind(self).call(*args, &block)
              self.class.queue << "result = \#{result}"
              result
            end
          }
          #puts body
          klass.class_eval body
        end
      end

      # opening existing Time class
      class Time
        include TraceMethodCalls_5

        class << self
          attr_accessor :queue
        end
        @queue = []
      end

      require 'time'
      ex = Time.parse("Sun Mar 25 14:33:20 CDT 2012")
      ex.localtime
      Time.queue.shift.should == "Calling method localtime with []"
      Time.queue.shift.should == "Calling method to_s with []"
      Time.queue.shift.should == "result = 2012-03-25 14:33:20 -0500"
      Time.queue.shift.should == "result = 2012-03-25 14:33:20 -0500"
    end
  end
  context '- sixth iteration' do
    it "should trace any existing class in Ruby 1.8 - try it with String class - turn tracing OFF for String class while doing the tracing" do
      module TraceMethodCalls_6
        def self.included(klass)
          method_hash = klass.const_set(:METHOD_HASH, {})
          suppress_tracing do 
            # instance_methods(false) because we don't want inherited methods
            klass.instance_methods(false).sort.each do |meth|
              # meth is provided as a string and not a symbol ( a total inconsistency in Ruby)
              wrap_method(klass, meth.to_sym)
            end
          end
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_6.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.suppress_tracing
          # old_value is needed to deal with nesting
          old_value = Thread.current[:'suppress tracing']
          # Thread.current returns the current thread and allows us to store whatever we want in its hash
          Thread.current[:'suppress tracing'] = true
          yield
        ensure  # no need for begin..end for ensure
          Thread.current[:'suppress tracing'] = old_value
        end
        def self.ok_to_trace?
          ! Thread.current[:'suppress tracing'] # if hash never been initialize, will return true
        end
        def self.wrap_method(klass, name)
          method_hash = klass.const_get(:METHOD_HASH)
          method_hash[name] = klass.instance_method(name)
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            def #{name}(*args, &block)
              if TraceMethodCalls_6.ok_to_trace?
                self.class.queue << "Calling method #{klass}\##{name} with \#{args.inspect}"
              end
              result = METHOD_HASH[:#{name}].bind(self).call(*args, &block)
              if TraceMethodCalls_6.ok_to_trace?
                self.class.queue << "#{klass}\##{name} result = \#{result}"
              end
              result
            end
          }
          #puts body
          klass.class_eval body
        end
      end

      # opening existing String class
      class String
        include TraceMethodCalls_6

        class << self
          attr_accessor :queue
        end
        @queue = []
      end

      var = "hello " + "hani"

      String.queue.shift.should == "Calling method String#inspect with []"
      String.queue.shift.should == "String#inspect result = \"hani\""
      String.queue.shift.should == "Calling method String#+ with [\"hani\"]"
      String.queue.shift.should == "String#+ result = hello hani"
    end
  end
  context '- seventh iteration' do
    it "should trace any existing class in Ruby 1.8 - with nested classes" do
      module TraceMethodCalls_7
        def self.included(klass)
          method_hash = klass.const_set(:METHOD_HASH, {})
          suppress_tracing do 
            # instance_methods(false) because we don't want inherited methods
            klass.instance_methods(false).sort.each do |meth|
              # meth is provided as a string and not a symbol ( a total inconsistency in Ruby)
              wrap_method(klass, meth.to_sym)
            end
          end
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_7.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.suppress_tracing
          # old_value is needed to deal with nesting
          old_value = Thread.current[:'suppress tracing']
          # Thread.current returns the current thread and allows us to store whatever we want in its hash
          Thread.current[:'suppress tracing'] = true
          yield
        ensure  # no need for begin..end for ensure
          Thread.current[:'suppress tracing'] = old_value
        end
        def self.ok_to_trace?
          ! Thread.current[:'suppress tracing'] # if hash never been initialize, will return true
        end
        def self.wrap_method(klass, name)
          method_hash = klass.const_get(:METHOD_HASH)
          method_hash[name] = klass.instance_method(name)
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            def #{name}(*args, &block)
              if TraceMethodCalls_7.ok_to_trace?
                self.class.queue << "Calling method #{klass}\##{name} with \#{args.inspect}"
              end
              result = METHOD_HASH[:#{name}].bind(self).call(*args, &block)
              if TraceMethodCalls_7.ok_to_trace?
                self.class.queue << "#{klass}\##{name} result = \#{result}"
              end
              result
            end
          }
          #puts body
          klass.class_eval body
        end
      end

      class One
        include TraceMethodCalls_7

        class << self
          attr_accessor :queue
        end
        @queue = []

        def one
          t = Two.new
          t.two
        end
      end

      class Two
        include TraceMethodCalls_7

        class << self
          attr_accessor :queue
        end
        @queue = []

        def two
          99
        end
      end

      One.new.one

      One.queue.shift.should == "Calling method One#one with []"
      Two.queue.shift.should == "Calling method Two#two with []"
      Two.queue.shift.should == "Two#two result = 99"
      One.queue.shift.should == "One#one result = 99"
    end
  end
  context '- eighth iteration' do
    it "should trace any existing class in Ruby 1.8 - with nested classes and dealing with recursive Array#inspect" do
      module TraceMethodCalls_8
        def self.included(klass)
          method_hash = klass.const_set(:METHOD_HASH, {})
          suppress_tracing do 
            # instance_methods(false) because we don't want inherited methods
            klass.instance_methods(false).sort.each do |meth|
              # meth is provided as a string and not a symbol ( a total inconsistency in Ruby)
              wrap_method(klass, meth.to_sym)
            end
          end
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_8.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.suppress_tracing
          # old_value is needed to deal with nesting
          old_value = Thread.current[:'suppress tracing']
          # Thread.current returns the current thread and allows us to store whatever we want in its hash
          Thread.current[:'suppress tracing'] = true
          yield
        ensure  # no need for begin..end for ensure
          Thread.current[:'suppress tracing'] = old_value
        end
        def self.ok_to_trace?
          ! Thread.current[:'suppress tracing'] # if hash never been initialize, will return true
        end
        def self.wrap_method(klass, name)
          method_hash = klass.const_get(:METHOD_HASH)
          method_hash[name] = klass.instance_method(name)
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            def #{name}(*args, &block)
              if TraceMethodCalls_8.ok_to_trace?
                TraceMethodCalls_8.suppress_tracing do 
                  self.class.queue << "Calling method #{klass}\##{name} with \#{args.inspect}"
                end
              end
              result = METHOD_HASH[:#{name}].bind(self).call(*args, &block)
              if TraceMethodCalls_8.ok_to_trace?
                TraceMethodCalls_8.suppress_tracing do 
                  self.class.queue << "#{klass}\##{name} result = \#{result}"
                end
              end
              result
            end
          }
          puts body
          klass.class_eval body
        end
      end

      class AOne
        include TraceMethodCalls_8

        class << self
          attr_accessor :queue
        end
        @queue = []

        def one
          t = ATwo.new
          t.two
        end
      end

      class ATwo
        include TraceMethodCalls_8

        class << self
          attr_accessor :queue
        end
        @queue = []

        def two
          99
        end
      end

      AOne.new.one

      AOne.queue.shift.should == "Calling method AOne#one with []"
      ATwo.queue.shift.should == "Calling method ATwo#two with []"
      ATwo.queue.shift.should == "ATwo#two result = 99"
      AOne.queue.shift.should == "AOne#one result = 99"

#     class Array
#       include TraceMethodCalls_8
#
#       class << self
#         attr_accessor :queue
#       end
#       @queue = []
#     end
    end
  end
end

