describe 'Enumerable predicates' do
  context '- all?' do
    items = %w(hello mello yello)
    it 'returns true if the given block evaluates to true for all items in the collection' do
      result = items.all? do |x|
        x.end_with?('llo')
      end
      expect(result).to eq true
    end
    it 'returns false if the given block evaluates to false for at least one item in the collection' do
      items << 'orange'
      result = items.all? do |x|
        x.end_with?('llo')
      end
      expect(result).to eq false
    end
  end

  context '- any?' do
    items = %w(hello orange red)
    it 'returns true if the given block evaluates to true for any item in the collection (at least one)' do
      result = items.any? do |x|
        x.end_with?('llo')
      end
      expect(result).to eq true
    end
    it 'returns false if the given block evaluates to false for all items in the collection (none of the items evaluates to true)' do
      result = items.any? do |x|
        x.end_with?('xxx')
      end
      expect(result).to eq false
    end
  end

  context '- include?(x)' do
    items = %w(hello orange red)
    it 'returns true if x is a member of the collection' do
      result = items.include?('red')
      expect(result).to eq true
    end
    it 'returns false if x is NOT a member of the collection' do
      result = items.include?('green')
      expect(result).to eq false
    end
  end

  context '- member?(x) (same as include)' do
    items = %w(hello orange red)
    it 'returns true if x is a member of the collection' do
      result = items.member?('red')
      expect(result).to eq true
    end
    it 'returns false if x is NOT a member of the collection' do
      result = items.member?('green')
      expect(result).to eq false
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
