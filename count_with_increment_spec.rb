describe 'count with increment method' do
  context "hanis solution" do
    class Counter
      def count_with_increment(start, inc)
        first_time = true
        lambda do
          if first_time
            first_time = false
            return start
          else
            return start = start + inc
          end
        end
      end
    end

    counter = Counter.new.count_with_increment(10,3)

    it "should return start first time called" do
      expect(counter.call).to eq 10
    end
    it "should return start + inc when called after first time(2nd)" do
      expect(counter.call).to eq 13
    end
    it "should return start + inc when called after first time(3rd)" do
      expect(counter.call).to eq 16
    end
    it "should return start + inc when called after first time(4th)" do
      expect(counter.call).to eq 19
    end
  end
  context "daves solution" do
    class Counter
      def count_with_increment(start, inc)
        start -= inc
        lambda { start += inc }
      end
    end

    counter = Counter.new.count_with_increment(10,3)

    it "should return start first time called" do
      expect(counter.call).to eq 10
    end
    it "should return start + inc when called after first time(2nd)" do
      expect(counter.call).to eq 13
    end
    it "should return start + inc when called after first time(3rd)" do
      expect(counter.call).to eq 16
    end
    it "should return start + inc when called after first time(4th)" do
      expect(counter.call).to eq 19
    end
  end
end
