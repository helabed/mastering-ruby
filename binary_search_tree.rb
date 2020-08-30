##comment out these 3 lines for standlone RSpec (i.e when NOT in coderpad)
#require 'rspec/autorun'
#require 'algorithms'
#  include Algorithms
##The above statements are useful when running in
##coderpad.io/sandbox - otherwise comment out
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'
require 'byebug'

RSpec.describe 'BinarySearchTree (BST) testing iteration 1' do
  it 'should search for an element stored in BST' do
    total_num_of_items = 5
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
#     [1,2,2,3,3,33,113],
#     [0,0,2,113,3],
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|

        item_to_search_for = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for # adds it because we want to search for it
        rand_array.shuffle!

        puts ""
        puts ""
        bs = BinarySearchTree.new
        #rand_array = [2, 5, 7, 1, 3, 4, 1]
        #item_to_search_for = 5
        bs.log rand_array, 'the array'
        bs.log item_to_search_for, 'Will be searching for'
        bs.insert_into(rand_array)
        bs.display_tree
        bs.search_for(rand_array, item_to_search_for)
      end
    end
  end
end

class BinarySearchTree
  LOG_LEVEL_DEBUG = 2
  LOG_LEVEL_INFO  = 1
  LOG_LEVEL_NONE  = false
  LOG_LEVEL = LOG_LEVEL_DEBUG

  def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end
  def info;      LOG_LEVEL == LOG_LEVEL_INFO;  end
  def quiet;     LOG_LEVEL == LOG_LEVEL_NONE;  end

  def log(msg, label='')
    if debugging
      print "-"*20; print label; print "-"*20; print "\n"; print "#{msg}\n" if msg
    end
  end

  attr_accessor :root_tree

  def initialize
    if @root_tree == nil
      @root_tree = Tree.new
      @root_tree.height = 1
      @root_tree.parent = nil
      log "", "Root Tree created #{@root_tree.display_tree}" if debugging
    end
  end

  def insert(node)
    @root_tree.insert_element(node)
  end

  def insert_into(arr)
    puts "" if debugging
    log arr, "Inserting Array Elements into BST" if debugging
    arr.each do |el|
      log nil, "Inserting Element #{el} into BST" if debugging
      insert(Node.new(el))
    end
  end

  def search_for(arr,val)
    log arr, "Finished Adding array -> BST"
    log '', "Searching BST for -> #{val}"
  end

  def bst_search(ar, val)
  end

  def display_tree
    if @root_tree
      log nil, "Displaying Tree"
      indent = 30
      puts "#{' '*(indent)}Root(d=#{@root_tree.height}) #{@root_tree.node.display_node}"
      @root_tree.display(indent)
    end
  end

  #
  #
  # BinarySearchTree::Node
  #
  class Node
    attr_accessor :data

    def initialize(data)
      @data = data
      puts "Node created with data #{data}"
    end

    def display
      puts "Displaying Node with #{data}"
    end

    def display_node
      "#{data}"
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\ndata: #{self.data}"
      s << "\n"
      return s
    end

    def dispose
      @data = nil
    end
  end
  # End of BinarySearchTree::Node

  #
  #
  # BinarySearchTree::Tree
  #
  class Tree
    attr_accessor :node
    attr_accessor :left_child
    attr_accessor :right_child
    attr_accessor :parent
    attr_accessor :height

    def initialize
      @node = nil
      @left_child = nil
      @right_child = nil
      @parent = nil
      @height = nil
    end

    def display_tree
      "w/hash: #{(self.hash % 1000)}"
    end

    def display(indent=35)
      indentation_shift = 5
      left_indent = indent - indentation_shift
      right_indent = indent + indentation_shift
      if @left_child && @right_child
        print "#{' '*left_indent}L(d=#{left_child.height}) "+
          "#{left_child.node.display_node}"
        print "#{' '*(indentation_shift*2)}R(d=#{right_child.height}) "+
          "#{right_child.node.display_node}\n"
        @left_child.display(left_indent)
        @right_child.display(indentation_shift*2)
      elsif @left_child && @right_child == nil
        puts "#{' '*left_indent}L(d=#{left_child.height}) "+
          "#{left_child.node.display_node}"
        @left_child.display(left_indent)
      elsif @left_child == nil && @right_child
        puts "#{' '*(right_indent)}R(d=#{right_child.height}) "+
          "#{right_child.node.display_node}"
        @right_child.display(right_indent)
      end
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\nheight: #{self.height}"
      s << "\nparent: "; if self.parent then "#{self.parent.node}" end
      s << "\nnode: #{self.node}"
      s << "\nleft_child: "; if self.left_child then "#{self.left_child}" end
      s << "\nright_child: "; if self.right_child then "#{self.right_child}" end
      s << "\n"
      return s
    end

    def insert_element(node)
      if @node == nil
        @node = node
        self.height = 1 if self.parent == nil
        puts "Tree at height #{self.height} inserted node #{node.display_node} into BST"
      elsif node.data < @node.data
        if @left_child == nil
          @left_child = Tree.new
          @left_child.parent = self
          @left_child.height = self.height + 1 if self.height
        end
        @left_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
             "was traversed-left towards node #{@left_child.node.display_node}"
      elsif node.data > @node.data
        if @right_child == nil
          @right_child =Tree.new
          @right_child.parent = self
          @right_child.height = self.height + 1 if self.height
        end
        @right_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
             "was traversed-right towards node #{@right_child.node.display_node}"
      else
        puts "Node #{node.display_node} is already in tree - ignoring"
      end
    end

    def delete_element(root, node)
    end

    def dispose
      @node.dispose        if @node
      @left_child.dispose  if @left_child
      @right_child.dispose if @right_child
    end
  end
  # End of BinarySearchTree::Tree
end
