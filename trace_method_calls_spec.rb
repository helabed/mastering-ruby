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
      expect(Example_1.queue.shift).to eq "Calling method a_method with [3, 4]"
      expect(Example_1.queue.shift).to eq "result = 7"
      ex.another_method(50) { 2 }
      expect(Example_1.queue.shift).to eq "Calling method another_method with [50]"
      expect(Example_1.queue.shift).to eq "result = 100"
      ex.empty_method
      expect(Example_1.queue.shift).to eq "Calling method empty_method with []"
      expect(Example_1.queue.shift).to eq "result = "
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
      expect(Example_2.queue.shift).to eq "Calling method a_method with [3, 4]"
      expect(Example_2.queue.shift).to eq "result = 7"
      ex.another_method(50) { 2 }
      expect(Example_2.queue.shift).to eq "Calling method another_method with [50]"
      expect(Example_2.queue.shift).to eq "result = 100"
      ex.empty_method
      expect(Example_2.queue.shift).to eq "Calling method empty_method with []"
      expect(Example_2.queue.shift).to eq "result = "
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
      expect(Example_3.queue.shift).to eq "Calling method a_method with [3, 4]"
      expect(Example_3.queue.shift).to eq "result = 7"
      ex.another_method(50) { 2 }
      expect(Example_3.queue.shift).to eq "Calling method another_method with [50]"
      expect(Example_3.queue.shift).to eq "result = 100"
      ex.name = 'fred'
      expect(Example_3.queue.shift).to eq "Calling method name= with [\"fred\"]"
      expect(Example_3.queue.shift).to eq "result = fred"
      ex << 'cat'
      expect(Example_3.queue.shift).to eq "Calling method << with [\"cat\"]"
      expect(Example_3.queue.shift).to eq "result = pushing cat"
    end
  end
  context '- sidenote - prove that a CONST is available from within both a Ruby class and its instance' do
    class MyClass
      MY_CONST = {:my_var => 'var_1'}
    end

    it "should have access to the CONST at the class level" do
      expect(MyClass::MY_CONST[:my_var]).to eq 'var_1'
    end

    it "should have access to the CONST from any instance of the class" do
      my_class = MyClass.new
      # one way of getting at the constant
      expect(my_class.class.const_get(:MY_CONST)[:my_var]).to eq 'var_1'
      # another way of getting at the constant
      expect(my_class.class::MY_CONST[:my_var]).to eq 'var_1'
      # yet another way of getting at the constant
      the_var = my_class.instance_eval { MyClass::MY_CONST[:my_var]}
      expect(the_var).to eq 'var_1'
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
      expect(Example_4.queue.shift).to eq "Calling method a_method with [3, 4]"
      expect(Example_4.queue.shift).to eq "result = 7"
      ex.another_method(50) { 2 }
      expect(Example_4.queue.shift).to eq "Calling method another_method with [50]"
      expect(Example_4.queue.shift).to eq "result = 100"
      ex.empty_method
      expect(Example_4.queue.shift).to eq "Calling method empty_method with []"
      expect(Example_4.queue.shift).to eq "result = "
      ex.name = 'fred'
      expect(Example_4.queue.shift).to eq "Calling method name= with [\"fred\"]"
      expect(Example_4.queue.shift).to eq "result = fred"
      ex << 'cat'
      expect(Example_4.queue.shift).to eq "Calling method << with [\"cat\"]"
      expect(Example_4.queue.shift).to eq "result = pushing cat"
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

      require 'time'
      ex = Time.parse("Sun Mar 25 14:33:20 CDT 2012")
      #puts ex.localtime

#
#     # opening existing Time class
#     class Time
#       include TraceMethodCalls_5
#
#       class << self
#         attr_accessor :queue
#       end
#       @queue = []
#     end

        # code below is crashing rspec 3.x and rspec running on coderpad.io/sandbox
#     expect(OurTime.class).to eq "Array"
#     expect(OurTime.queue.shift).to eq "Calling method localtime with []"
#     expect(Time.queue.class).to eq "Array"
#     expect(Time.queue.shift).to eq "Calling method localtime with []"
#     expect(Time.queue.shift).to eq "Calling method to_s with []"
#     expect(#Time.queue.shift).to eq "result = Sun Mar 25 14:33:20 -0500 2012"
#     expect(Time.queue.shift).to eq "result = 2012-03-25 14:33:20 -0500"
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

      expect(String.queue.shift).to eq "Calling method String#inspect with []"
      expect(String.queue.shift).to eq "String#inspect result = \"hani\""
      expect(String.queue.shift).to eq "Calling method String#+ with [\"hani\"]"
      expect(String.queue.shift).to eq "String#+ result = hello hani"
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

      expect(One.queue.shift).to eq "Calling method One#one with []"
      expect(Two.queue.shift).to eq "Calling method Two#two with []"
      expect(Two.queue.shift).to eq "Two#two result = 99"
      expect(One.queue.shift).to eq "One#one result = 99"
    end
  end
  context '- eighth iteration' do
    it "should trace any existing class in Ruby 1.8 - with nested classes and dealing with recursive Array#inspect" do
      module TraceMethodCalls_8
        def self.included(klass)
          method_hash = klass.const_set(:METHODS_HASH, {})
          # instance_methods(false) because we don't want inherited methods
          suppress_tracing do
            if klass == Array
              klass.instance_methods(false).each do |meth|
                # meth is provided as a string in Ruby 1.8 and not a symbol ( a total inconsistency in Ruby)
                # had to pre-empt these Array methods otherwise I could not Trace any other array methods
                arr = [
                         '+',
                         '<<',
                         'each',
                         'empty?',
                         'reject',
                         'reverse',
                         'reverse_each',
                         'select',
                      ]

                unless arr.include? "#{meth}"
                  wrap_method(klass, meth.to_sym)
                end
              end
            else
              suppress_tracing do
                klass.instance_methods(false).sort.each do |meth|
                  # meth is provided as a string and not a symbol ( a total inconsistency in Ruby)
                  wrap_method(klass, meth.to_sym)
                end
              end
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
          method_hash = klass.const_get(:METHODS_HASH)
          method_hash[name] = klass.instance_method(name)
          # inside here, we are overwriting the method name with our own tracing method
          body = %{
            def #{name}(*args, &block)
              if TraceMethodCalls_8.ok_to_trace?
                TraceMethodCalls_8.suppress_tracing do
                  self.class.queue << "Calling method #{klass}\##{name} with \#{args.inspect}"
                end
              end
              result = METHODS_HASH[:#{name}].bind(self).call(*args, &block)
              if TraceMethodCalls_8.ok_to_trace?
                TraceMethodCalls_8.suppress_tracing do
                  self.class.queue << "#{klass}\##{name} result = \#{result}"
                end
              end
              result
            end
          }
          #puts body
          klass.class_eval body
        end
      end

      class Array
        include TraceMethodCalls_8

        class << self
          attr_accessor :queue
        end
        @queue = []
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

      expect(AOne.queue.shift).to eq "Calling method AOne#one with []"
      expect(ATwo.queue.shift).to eq "Calling method ATwo#two with []"
      expect(ATwo.queue.shift).to eq "ATwo#two result = 99"
      expect(AOne.queue.shift).to eq "AOne#one result = 99"
    end
  end
  context '- nineth iteration' do
    it "should trace any existing class in Ruby 1.9 - with nested classes and with method_define with block support" do
      module TraceMethodCalls_9
        def self.included(klass)
          method_hash = klass.const_set(:METHOD_HASH, {})
          # instance_methods(false) because we don't want inherited methods
          suppress_tracing do
            if klass == Array
              klass.instance_methods(false).each do |meth|
                # meth is provided as a string in Ruby 1.8 and not a symbol ( a total inconsistency in Ruby)
                # had to pre-empt these Array methods otherwise I could not Trace any other array methods
                arr = [
                         '+',
                         '<<',
                         'each',
                         'empty?',
                         'reject',
                         'reverse',
                         'reverse_each',
                         'select',
                      ]

                unless arr.include? "#{meth}"
                  #puts "I am with #{meth}"
                  wrap_method(klass, meth.to_sym)
                end
              end
            else
              suppress_tracing do
                klass.instance_methods(false).sort.each do |meth|
                  # meth is provided as a string and not a symbol ( a total inconsistency in Ruby)
                  wrap_method(klass, meth.to_sym)
                end
              end
            end
          end
          # inside body of method_added, self is set to klass
          def klass.method_added(name)
            return if @_adding_a_method
            @_adding_a_method = true
            TraceMethodCalls_9.wrap_method(self, name)
            @_adding_a_method = false
          end
        end
        def self.suppress_tracing
          # old_value is needed to deal with nesting
          old_value = Thread.current[:'suppress tracing 9']
          # Thread.current returns the current thread and allows us to store whatever we want in its hash
          Thread.current[:'suppress tracing 9'] = true
          yield
        ensure  # no need for begin..end for ensure
          Thread.current[:'suppress tracing 9'] = old_value
        end
        def self.ok_to_trace?
          ! Thread.current[:'suppress tracing 9'] # if hash never been initialize, will return true
        end
        def self.wrap_method(klass, name)
          #puts "inside wrap_method, self is: #{self.inspect} and name is: #{name}"
          klass.class_eval do
            #puts "inside klass.class_eval, self is: #{self.inspect}, and name is: #{name}"
            original_method = instance_method(name)
            # inside here, we are overwriting the method name with our own tracing method
            define_method(name) do |*args, &block|
              if TraceMethodCalls_9.ok_to_trace?
                TraceMethodCalls_9.suppress_tracing do
                  self.class.queue << "==> Calling method #{klass}\##{name} with #{args.inspect}"
                end
              end
              result = original_method.bind(self).call(*args, &block)
              if TraceMethodCalls_9.ok_to_trace?
                TraceMethodCalls_9.suppress_tracing do
                  self.class.queue << "<== #{klass}\##{name} result = #{result}"
                end
              end
              result
            end
          end
        end
      end

      class AAOne
        include TraceMethodCalls_9

        class << self
          attr_accessor :queue
        end
        @queue = []

        def one
          t = AATwo.new
          t.two
        end
      end

      class AATwo
        include TraceMethodCalls_9

        class << self
          attr_accessor :queue
        end
        @queue = []

        def two
          99
        end
      end

      AAOne.new.one

      expect(AAOne.queue.shift).to eq "==> Calling method AAOne#one with []"
      expect(AATwo.queue.shift).to eq "==> Calling method AATwo#two with []"
      expect(AATwo.queue.shift).to eq "<== AATwo#two result = 99"
      expect(AAOne.queue.shift).to eq "<== AAOne#one result = 99"

      class Example_9
        include TraceMethodCalls_9

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
      ex = Example_9.new
      ex.a_method(3,4)
      expect(Example_9.queue.shift).to eq "==> Calling method Example_9#a_method with [3, 4]"
      expect(Example_9.queue.shift).to eq "<== Example_9#a_method result = 7"
      ex.another_method(50) { 2 }
      expect(Example_9.queue.shift).to eq "==> Calling method Example_9#another_method with [50]"
      expect(Example_9.queue.shift).to eq "<== Example_9#another_method result = 100"
      ex.name = 'fred'
      expect(Example_9.queue.shift).to eq "==> Calling method Example_9#name= with [\"fred\"]"
      expect(Example_9.queue.shift).to eq "<== Example_9#name= result = fred"
      ex << 'cat'
      expect(Example_9.queue.shift).to eq "==> Calling method Example_9#<< with [\"cat\"]"
      expect(Example_9.queue.shift).to eq "<== Example_9#<< result = pushing cat"

    end
  end
end
