describe 'Enumerable filters' do
  context '- find' do
    items = %w(hello mello yello)
    it 'returns the first item in the collection for which the block evaluates to true' do
      result = items.find do |x|
        x.end_with?('llo')
      end
      expect(result).to eq 'hello'
    end
    it 'returns nil if no such item was found' do
      result = items.find do |x|
        x.end_with?('red')
      end
      expect(result).to eq nil
    end
  end
  context '- detect (same as find)' do
    items = %w(hello mello red)
    it 'returns the first item in the collection for which the block evaluates to true' do
      result = items.detect do |x|
        x.end_with?('ed')
      end
      expect(result).to eq 'red'
    end
    it 'returns nil if no such item was found' do
      result = items.detect do |x|
        x.end_with?('xxx')
      end
      expect(result).to eq nil
    end
  end
  context '- find_all' do
    items = %w(hello mello yello)
    it 'returns all items in the collection for which the block evaluates to true' do
      result = items.find_all do |x|
        x.end_with?('llo')
      end
      expect(result).to eq ['hello', 'mello', 'yello']
    end
    it 'returns empty array if no such item was found' do
      result = items.find_all do |x|
        x.end_with?('red')
      end
      expect(result).to eq []
    end
  end
  context '- select (same as find_all)' do
    items = %w(hello mello yello)
    it 'returns all items in the collection for which the block evaluates to true' do
      result = items.select do |x|
        x.end_with?('llo')
      end
      expect(result).to eq ['hello', 'mello', 'yello']
    end
    it 'returns empty array if no such item was found' do
      result = items.select do |x|
        x.end_with?('red')
      end
      expect(result).to eq []
    end
  end
  context '- reject' do
    items = %w(hello mello yellow)
    it 'returns all items in the collection for which the block evaluates to false (i.e removes items w/truthy blocks)' do
      result = items.reject do |x|
        x.end_with?('llow')
      end
      expect(result).to eq ['hello', 'mello']
    end
    it 'returns empty array if none of the items for which the block evaluates to false' do
      result = items.reject do |x|
        x.include?('llo')
      end
      expect(result).to eq []
    end
  end
  context '- grep(x) or grep(/x/)' do
    items = %w(hello mello yellow)
    it 'returns all items in the collection for which x === item (i.e exact match)' do
      result = items.grep('mello')
      expect(result).to eq ['mello']
    end
    it 'returns all items in the collection for which x ~= item (i.e item.match(/x/) - example 1)' do
      result = items.grep(/llo/)
      expect(result).to eq ['hello','mello','yellow']
    end
    it 'returns all items in the collection for which x ~= item (i.e item.match(/x/) - example 2)' do
      result = items.grep(/llow/)
      expect(result).to eq ['yellow']
    end
    it 'returns all items in the collection for which x ~= item (i.e item.match(/x/) - example 3)' do
      result = items.grep(/llo\b/)  # \b for word boundary
      expect(result).to eq ['hello','mello']
    end
  end
end
