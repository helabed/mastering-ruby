
describe 'my_attr_accessor' do
  before(:each) do
    module Logger
      def self.log(msg)
        msg
      end
    end

    module MyAccessor
      include Logger
      def my_attr_accessor(name)
        ivar_name = "@#{name}"
        define_method(name) do
          instance_variable_get(ivar_name)
        end
        define_method("#{name}=") do |val|
          instance_variable_set(ivar_name, val)
          Logger.log( "#{self.class}@#{name} => #{val}" )
        end
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

  context "provides an alternative implementation of attr_accessor with logging support" do
    it "should allow us to use it from any class" do
      e = Example.new
      e.table.should == nil
      e.table= 'clients'
      e.table.should == 'clients'
      e.table= 'Customers'
      e.table.should == 'Customers'
    end
  end

  context "a symbol is converted to string automatically when interpolated inside a string" do
    it "should produce a string class" do
      my_symbol = :ivar
      my_symbol.class.should == Symbol
      "#{my_symbol}".should == 'ivar'
      "#{my_symbol}".class.should == String
    end
  end
end

