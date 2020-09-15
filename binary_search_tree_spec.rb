#in coderpad.io/sandbox, copy file binary_search_tree.rb
#to the bottom of this file and comment out this
#require line below.
require './binary_search_tree'
#comment out this line below for standlone RSpec (i.e when NOT in coderpad)
require 'rspec/autorun'
##The above statements are useful when running in
##coderpad.io/sandbox - otherwise comment out
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'
#require 'byebug'


RSpec.describe 'BinarySearchTree (BST) Specification' do
  context 'Traversal and Search' do
    before(:all) do
      @bst = BinarySearchTree.new
      L = Logger
      L.set_level(Logger::LOG_LEVEL_NONE)

      @rand_array = [3,1,2,0,5,4,6]
      @bst.insert_into(@rand_array)
    end
    it 'the first element should be the root' do
      expect(@bst.root_tree.node.data).to eq 3
    end

    it 'should be able to display all elements in order' do
      accumulator = []
      @bst.root_tree.in_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [0,1,2,3,4,5,6]
    end

    it 'should be able to display all elements pre order' do
      accumulator = []
      @bst.root_tree.pre_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [3,1,0,2,5,4,6]
    end

    it 'should be able to display all elements post order' do
      accumulator = []
      @bst.root_tree.post_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [0,2,1,4,6,5,3]
    end

    it 'should be able to search and locate an element' do
       item_to_search_for = 2
       found, data = @bst.search_for(@rand_array, item_to_search_for)
       expect(found).to be true
       expect(data).to eq item_to_search_for
    end

    it 'should be able to display height of the tree' do
      expect(@bst.height_of_tree).to eq(3)
    end

    it 'should be able to display all leaf elements right to left' do
      accumulator = []
      @bst.root_tree.right_to_left_leaf_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [6,4,2,0]
    end

    it 'should be able to display all ancestor elements from root to a certain node' do
      item_to_traverse_from = 2
      accumulator = []
      outcome = @bst.do_ancestors_traverse(item_to_traverse_from) do |t|
        accumulator << t.node.data
      end
      expect(outcome).to be true
      expect(accumulator).to eq [3,1]
    end

    it 'should be able to display all descendant elements from a certain node and to all its leaves' do
      item_to_traverse_from = 3
      accumulator = []
      outcome = @bst.do_descendants_traverse(item_to_traverse_from) do |t|
        accumulator << t.node.data
      end
      expect(outcome).to be true
      expect(accumulator).to eq [1,0,2,5,4,6]
    end
  end

  context 'deleting elements from the BST' do
    before(:each) do
      @bst = BinarySearchTree.new
      @rand_array = [3,1,2,0,5,4,6]
      @bst.insert_into(@rand_array)
    end
    it 'should be able to delete a right leaf element' do
      item_to_delete = 2
      outcome = @bst.delete_from(item_to_delete)
      expect(outcome).to be true
      accumulator = []
      @bst.root_tree.in_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [0,1,3,4,5,6]
    end

    it 'should be able to delete a left leaf element' do
      item_to_delete = 0
      outcome = @bst.delete_from(item_to_delete)
      expect(outcome).to be true
      accumulator = []
      @bst.root_tree.in_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [1,2,3,4,5,6]
    end

    it 'should be able to delete an element with 2 children' do
      item_to_delete = 1
      outcome = @bst.delete_from(item_to_delete)
      expect(outcome).to be true
      accumulator = []
      @bst.root_tree.in_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [0,2,3,4,5,6]
    end

    it 'should be able to delete an element with 1 child' do
      # remove one of the 2 children first
      item_to_delete = 0
      outcome = @bst.delete_from(item_to_delete)
      expect(outcome).to be true

      # then assert other child removed okay
      item_to_delete = 1
      outcome = @bst.delete_from(item_to_delete)
      expect(outcome).to be true
      accumulator = []
      @bst.root_tree.in_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [2,3,4,5,6]
    end

    it 'should be able to delete the root element' do
      # remove one of the 2 children first
      item_to_delete = 3
      outcome = @bst.delete_from(item_to_delete)
      expect(outcome).to be true
      accumulator = []
      @bst.root_tree.in_order_traverse do |t|
        accumulator << t.node.data
      end
      expect(accumulator).to eq [0,1,2,4,5,6]
      # expect new root to be the in-order successor (or predecessor)
      expect(@bst.root_tree.node.data).to eq 4
    end
  end
end
