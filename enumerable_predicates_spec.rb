describe 'Enumerable predicates' do
  context '- all?' do
    items = %w(hello mello yello)
    it 'returns true if the given block evaluates to true for all items in the collection' do
      result = items.all? do |x|
        x.end_with?('llo')
      end
      result.should == true
    end
    it 'returns false if the given block evaluates to false for at least one item in the collection' do
      items << 'orange'
      result = items.all? do |x|
        x.end_with?('llo')
      end
      result.should == false
    end
  end

  context '- any?' do
    items = %w(hello orange red)
    it 'returns true if the given block evaluates to true for any item in the collection (at least one)' do
      result = items.any? do |x|
        x.end_with?('llo')
      end
      result.should == true
    end
    it 'returns false if the given block evaluates to false for all items in the collection (none of the items evaluates to true)' do
      result = items.any? do |x|
        x.end_with?('xxx')
      end
      result.should == false
    end
  end

  context '- include?(x)' do
    items = %w(hello orange red)
    it 'returns true if x is a member of the collection' do
      result = items.include?('red')
      result.should == true
    end
    it 'returns false if x is NOT a member of the collection' do
      result = items.include?('green')
      result.should == false
    end
  end

  context '- member?(x) (same as include)' do
    items = %w(hello orange red)
    it 'returns true if x is a member of the collection' do
      result = items.member?('red')
      result.should == true
    end
    it 'returns false if x is NOT a member of the collection' do
      result = items.member?('green')
      result.should == false
    end
  end


end
