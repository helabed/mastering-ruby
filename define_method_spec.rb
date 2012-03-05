describe 'define_method' do
  context "is available only inside a class or a module" do
    it "should allow us to create a simple statically named method inside a class" do
      class Multiplier
        define_method(:times_2) do |val|
          val * 2
        end
      end
      m = Multiplier.new
      m.times_2(3).should == 6
    end
    context "it should allow us to create a simple statically named method inside a module" do
      module MultiplierFactory
        define_method(:times_5) do |val|
          val * 5
        end
      end
      it "can access the method when using the 'include' keyword" do
        class Multiplier
          include MultiplierFactory
        end
        m = Multiplier.new
        m.times_5(5).should == 25
      end
      it "can access the method when using the 'extend' keyword" do
        class MultiplierWithExtend
          extend MultiplierFactory
        end
        MultiplierWithExtend.times_5(10).should == 50
      end
    end
    it "should allow us to create a dynamically named method inside a class" do
      class Multiplier
        def self.create_n_times(n)
          define_method("times_#{n}") do |val|
            val * n
          end
        end
      end
      Multiplier.create_n_times(2)
      m = Multiplier.new
      m.times_2(3).should == 6
    end
    it "should allow us to create many dynamically named methods(i.e many similar methods) inside a class" do
      class Multiplier
        def self.create_n_times(n)
          define_method("times_#{n}") do |val|
            val * n
          end
        end
        (2..10).each do |x|
          Multiplier.create_n_times(x)
        end
      end
      m = Multiplier.new
      m.times_2(3).should == 6
      m.times_5(3).should == 15
      m.times_8(10).should == 80
    end
  end
end
