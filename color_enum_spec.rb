describe 'color enumeration' do
  context 'using different classes' do
    it "should define color enumeration classes on the fly" do
      class Color
        def self.const_missing(name)
          const_set(name, new)
        end
      end
      Color::Red.should == Color::Red
      Color::Red.should_not == Color::Orange
    end
    it "should be distinct from other classes color enumeration schemes" do
      class ThreatLevel
        def self.const_missing(name)
          const_set(name, new)
        end
      end
      Color::Red.should_not == ThreatLevel::Red
      Color::Orange.should_not == ThreatLevel::Orange
      ThreatLevel::Red.should == ThreatLevel::Red
    end
  end
  context 'using Single Enum class' do
    it "should define color enumeration classes on the fly without conflicting with others and remember its name" do
      class Enum
        def self.new
          Class.new do
            def initialize(name)
              @name = name
            end
            def to_s
              "#{self.class.name}->#{@name}"
            end
            def self.const_missing(name)
              const_set(name, new(name))
            end
          end
        end
      end
      # to undefine above classes to avoid the warning: 'already initialized constant'
      Object.send(:remove_const, :ThreatLevel)
      Object.send(:remove_const, :Color)

      ThreatLevel = Enum.new
      Color = Enum.new

      Color::Red.should == Color::Red
      Color::Red.should_not == Color::Orange
      Color::Orange.should_not == ThreatLevel::Orange
      ThreatLevel::Red.should == ThreatLevel::Red
      ThreatLevel::Red.should_not == ThreatLevel::Orange

      Color::Red.to_s.should == 'Color->Red'
      ThreatLevel::Orange.to_s.should == "ThreatLevel->Orange"
    end
  end
end
