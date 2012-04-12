describe 'Enumerable filters' do
  context '- find' do
    items = %w(hello mello yello)
    it 'returns the first item in the collection for which the block evaluates to true' do
      result = items.find do |x|
        x.end_with?('llo')
      end
      result.should == 'hello'
    end
    it 'returns nil if no such item was found' do
      result = items.find do |x|
        x.end_with?('red')
      end
      result.should == nil
    end
  end
  context '- detect (same as find)' do
    items = %w(hello mello red)
    it 'returns the first item in the collection for which the block evaluates to true' do
      result = items.detect do |x|
        x.end_with?('ed')
      end
      result.should == 'red'
    end
    it 'returns nil if no such item was found' do
      result = items.detect do |x|
        x.end_with?('xxx')
      end
      result.should == nil
    end
  end
  context '- find_all' do
    items = %w(hello mello yello)
    it 'returns all items in the collection for which the block evaluates to true' do
      result = items.find_all do |x|
        x.end_with?('llo')
      end
      result.should == ['hello', 'mello', 'yello']
    end
    it 'returns empty array if no such item was found' do
      result = items.find_all do |x|
        x.end_with?('red')
      end
      result.should == []
    end
  end
  context '- select (same as find_all)' do
    items = %w(hello mello yello)
    it 'returns all items in the collection for which the block evaluates to true' do
      result = items.select do |x|
        x.end_with?('llo')
      end
      result.should == ['hello', 'mello', 'yello']
    end
    it 'returns empty array if no such item was found' do
      result = items.select do |x|
        x.end_with?('red')
      end
      result.should == []
    end
  end
  context '- reject' do
    items = %w(hello mello yellow)
    it 'returns all items in the collection for which the block evaluates to false' do
      result = items.reject do |x|
        x.end_with?('llow')
      end
      result.should == ['hello', 'mello']
    end
    it 'returns empty array if none of the items for which the block evaluates to false' do
      result = items.reject do |x|
        x.include?('llo')
      end
      result.should == []
    end
  end
  context '- grep(x)' do
    items = %w(hello mello yellow)
    it 'returns all items in the collection for which x === item' do
      result = items.grep('mello')
      result.should == ['mello']
    end
  end
end
