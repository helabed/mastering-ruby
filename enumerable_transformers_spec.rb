describe 'Enumerable transformers' do
  context '- map' do
    items = %w(hello mello yello)
    it 'returns the transformed collection for which the block is applied to each element of original collection' do
      result = items.map do |x|
        x + 'w'
      end
      expect(result).to eq ['hellow', 'mellow', 'yellow']
    end
  end
  context '- collect (same as map)' do
    items = %w(hello mello yello)
    it 'returns the transformed collection for which the block is applied to each element of original collection' do
      result = items.collect do |x|
        x + 'w'
      end
      expect(result).to eq ['hellow', 'mellow', 'yellow']
    end
  end
  context '- partition (same as [select(&block), reject(&block)])' do
    items = %w(hello mello yellow)
    it 'returns 2 arrays for which all items in the collection whose blocks evaluate to true and false, respectively' do
      result = items.partition do |x|
        x.end_with?('llow')
      end
      expect(result).to eq [['yellow'], ['hello', 'mello']]
    end
  end
  context '- sort' do
    items = %w(yello mello hello)
    it 'returns the transformed sorted collection by the given block or the elements own <=> operator' do
      result = items.sort do |x, y|
        x <=> y
      end
      expect(result).to eq ['hello', 'mello', 'yello']
    end
  end
  context '- sort_by' do
    it 'returns sorted collection using criteria in given block' do
      result = %w{ apple pear fig }.sort_by {|word| word.length}
      expect(result).to eq ['fig', 'pear', 'apple']
    end
  end
  context 'Enumerable methods' do
    Enumerable_methods = <<-METHODS
      https://apidock.com/ruby/Enumerable
      Enumerable#methods:
        all?         collect         drop_while        entries     find_all    group_by    lazy     min        partition     slice_after   take        uniq
        any?         collect_concat  each_cons         exclude?    find_index  include?    many?    min_by     pluck         slice_before  take_while  without
        as_json      count           each_entry        excluding   first       including   map      minmax     reduce        slice_when    tally       zip
        chain        cycle           each_slice        filter      flat_map    index_by    max      minmax_by  reject        sort          to_a
        chunk        detect          each_with_index   filter_map  grep        index_with  max_by   none?      reverse_each  sort_by       to_h
        chunk_while  drop            each_with_object  find        grep_v      inject      member?  one?       select        sum           to_set
    METHODS
  end
end
