require 'rspec/autorun'

RSpec.describe 'Struct' do

  context 'a Struct allows bundling a number of attributes together without needing an explicit class' do
    context 'a struct member is either a quoted string ("name") or a Symbol (:name)' do
      Customer = Struct.new(:name, :address, 'age') do
        def greeting
          "Hello #{name}!"
        end
      end

      it "should create a reader and writer method for each member declared in Struct.new" do
        dave = Customer.new("Dave", "123 Main", 23)

        expect(dave.name).to     eq("Dave")
        expect(dave.address).to  eq("123 Main")
        expect(dave.age).to      eq(23)
        expect(dave.greeting).to eq("Hello Dave!")
      end
    end
  end

  context 'the Struct class generates new subclasses that hold a set of members and their values' do
    class Struct
      @children = []
      def self.inherited(klass)
        @children << klass
      end
      def self.children
        @children
      end
    end

    Dave = Struct.new(:name)
    Fred = Struct.new(:age)

    it "should confirm that all classes created using Struct are indeed all its subclasses" do
      expect(Struct.children).to include(Dave, Fred)
    end
  end
end
