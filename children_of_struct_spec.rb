describe 'children of Struct' do

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

  it "should display all its subclasses" do
    Struct.children.should == [Dave, Fred]
  end
end
