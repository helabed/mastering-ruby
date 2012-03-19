describe 'ruby hook methods' do
  context "- method related hooks: " do
    context "method_missing" do
      it "should do method_missing" do
        #pending("not done yet")
      end
    end
    context "method_added" do
      it "should do method_added" do
        #pending("not done yet")
      end
    end
    context "singleton_method_added" do
      it "should do singleton_method_added" do
        #pending("not done yet")
      end
    end
    context "method_removed" do
      it "should do method_removed" do
        #pending("not done yet")
      end
    end
    context "singleton_method_removed" do
      it "should do singleton_method_removed" do
        #pending("not done yet")
      end
    end
    context "method_undefined" do
      it "should do method_undefined" do
        #pending("not done yet")
      end
    end
    context "singleton_method_undefined" do
      it "should do singleton_method_undefined" do
        #pending("not done yet")
      end
    end

  end




  context "- for Classes and Modules: " do
    context "inherited" do
      it "should do inherited" do
        class Parent
          def self.inherited(klass)
            puts "#{self} was inherited by #{klass}"
          end
        end
        class Child < Parent
        end
        class AnotherChild < Parent
        end
      end
    end
    context "append_features" do
      it "should do append_features" do
        #pending("not done yet")
      end
    end
    context "included" do
      it "should do included" do
        #pending("not done yet")
      end
    end
    context "extend_object" do
      it "should do extend_object" do
        #pending("not done yet")
      end
    end
    context "extended" do
      it "should do extended" do
        #pending("not done yet")
      end
    end
    context "initialize_copy" do
      it "should do initialize_copy" do
        #pending("not done yet")
      end
    end
    context "const_missing" do
      it "should do const_missing by brute force overriding original" do
        class Module
          @stack = []
          def const_missing(name)
            @stack.push "Missing #{name}"
          end
          def self.stack
            @stack
          end
          def self.call_ben
            Ben
          end
        end
        Module.call_ben
        Module.stack.pop.should == 'Missing Ben'
      end
      it "should do const_missing by using method alias chain and delegating to original when needed" do
        class Module
          @stack = []

          original_c_m = instance_method(:const_missing)

          define_method(:const_missing) do |name|
            if name.to_s =~ /Ben/
              @stack.push "Missing #{name}"
            else
              original_c_m.bind(self).call(name)
            end
          end
          def self.stack
            @stack
          end
          def self.call_ben
            Ben
          end
        end
        Module.call_ben
        Module.stack.pop.should == 'Missing Ben'
        lambda {Fred}.should raise_error(NameError)
      end
      it "should be restricted to a single class or module when defined inside this class or module" do
        class Dave
          @stack = []

          def self.const_missing(name)
            @stack.push "Missing #{name} in Dave"
          end
          def self.stack
            @stack
          end
          def self.call_ben
            Dave::Ben
          end
        end
        Dave.call_ben
        Dave.stack.pop.should == 'Missing Ben in Dave'
        lambda {Fred}.should raise_error(NameError)
      end
    end
  end




  context "- for Marshalling: " do
    context "marshal_dump" do
      it "should do marshal_dump" do
        #pending("not done yet")
      end
    end
    context "marshal_load" do
      it "should do marshal_load" do
        #pending("not done yet")
      end
    end
  end




  context "- for Coercion: " do
    context "coerce" do
      it "should do coerce" do
        #pending("not done yet")
      end
    end
    context "induced_from" do
      it "should do induced_from" do
        #pending("not done yet")
      end
    end
    context "to_s" do
      it "should do to_s" do
        #pending("not done yet")
      end
    end
    context "to_sym" do
      it "should do to_sym" do
        #pending("not done yet")
      end
    end
    context "to_proc" do
      it "should do to_proc" do
        #pending("not done yet")
      end
    end
    context "to_string" do
      it "should do to_string" do
        #pending("not done yet")
      end
    end
  end








  context '- example of including comparable' do
    it "should trigger the space-ship operator (<=>) method" do
      class SomeClass
        include Comparable

        def <=>(other)
          -1
        end
      end
      s = SomeClass.new
      (s < 123).should == true
    end
    it "should trigger the Ruby built-in hook method included" do
      class Module
        def included(mod)
          #puts "#{self} included in #{mod}"
        end
      end
      class OtherClass
        include Comparable

        def <=>(other)
          -1
        end
      end
      s = OtherClass.new
      (s < 123).should == true
    end
  end
end