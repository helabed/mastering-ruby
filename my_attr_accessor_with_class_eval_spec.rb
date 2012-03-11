describe 'my_attr_accessor_with_class_eval' do
  before(:each) do
    module MyAccessor
      def my_attr_accessor(name)
        class_eval %{
          def #{name}
            @#{name}
          end 
          def #{name}=(val)
            @#{name} = val
          end 
        }
        #ivar_name = "@#{name}"
        #define_method(name) do
        #  instance_variable_get(ivar_name)
        #end
        #define_method("#{name}=") do |val|
        #  instance_variable_set(ivar_name, val)
        #end
      end
    end

    class Example
      # we use 'extend' to access the my_attr_accessor method from within
      # this class level, and not at the instance level which would have
      # required 'include' instead of 'extend'
      extend MyAccessor

      # we are accessing my_attr_accessor at the class level of Excample class
      my_attr_accessor :table
    end
  end

  context "provides an alternative implementation of attr_accessor with class_eval instead of define_method because class_eval is more efficient in memory and speed" do
    it "should allow us to use it from any class" do
      e = Example.new
      e.table.should == nil
      e.table= 'clients'
      e.table.should == 'clients'
      e.table= 'Customers'
      e.table.should == 'Customers'
    end
  end
end

