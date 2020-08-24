describe 'enumeration' do
  context 'using many different enumeration classes' do
    it "should define enumeration classes on the fly (ex: Color or ThreatLevel)" do
      class Color
        def self.const_missing(name)
          const_set(name, new)
        end
      end
      expect(Color::Red).to eq Color::Red
      expect(Color::Red).to_not eq Color::Orange
    end
    it "should be distinct from other enumeration classes (ex: Color vs. ThreatLevel)" do
      class ThreatLevel
        def self.const_missing(name)
          const_set(name, new)
        end
      end
      expect(Color::Red).to_not eq ThreatLevel::Red
      expect(Color::Orange).to_not eq ThreatLevel::Orange
      expect(ThreatLevel::Red).to eq ThreatLevel::Red
    end
  end
  context 'using a single Enum class for all kind of enumerations' do
    it "should define Color or ThreatLevel enumeration on the fly without conflicting and remember its name/value" do
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

      expect(Color::Red).to eq Color::Red
      expect(Color::Red).to_not eq Color::Orange
      expect(Color::Orange).to_not eq ThreatLevel::Orange
      expect(ThreatLevel::Red).to eq ThreatLevel::Red
      expect(ThreatLevel::Red).to_not eq ThreatLevel::Orange

      expect(Color::Red.to_s).to eq 'Color->Red'
      expect(ThreatLevel::Orange.to_s).to eq "ThreatLevel->Orange"
    end
  end
end
