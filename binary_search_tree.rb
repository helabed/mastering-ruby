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
    total_num_of_items = 6
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
#     [1,2,2,3,3,33,113],
#     [0,0,2,113,3],
#     [0,1,3,113,3],
#     [1,90,1131,2,0],
#     [2,3,113,3,3],
#     [2,113,0,1,3]
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
        #rand_array = [498, 491, 134, 736, 35, 232, 212, 405, 183, 650, 273]
        #item_to_search_for = 35
        #rand_array = [1,2,2,3,3,33,113]
        #item_to_search_for = 33
        bs.log rand_array, 'the array'
        bs.log item_to_search_for, 'Search for'
        bs.insert_into(rand_array)
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

  attr_accessor :root_tree

  def initialize
    if @root_tree == nil
      @root_tree = Tree.new
      log "", "Root Tree created #{@root_tree.display_tree}" if debugging
    end
  end

  def insert(node)
    @root_tree.insert_element(node)
  end

  def insert_into(arr)
    puts "" if debugging
    log arr, "Inserting Random Array into BST" if debugging
    arr.each do |el|
      log nil, "Inserting Element #{el} into BST" if debugging
      insert(Node.new(el))
    end
  end

  def search_for(arr,val)
    log arr, "This array -> BST"
    update_tree
    display_tree
  end

  def bst_search(ar, val)
  end

  def display_tree
    if @root_tree
      log nil, "Displaying Tree"
      indent = 35
      depth = 1
      puts "#{' '*(indent)}Root(d=#{depth},d=#{@root_tree.depth}) #{@root_tree.node.display_node}"
      @root_tree.display(indent, depth)
    end
  end

  def update_tree
    if @root_tree
      log nil, "Updating Tree Parents and Depth"
      @root_tree.depth = 1
      @root_tree.parent = nil
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

  #
  #
  # BinarySearchTree::Tree
  #
  class Tree
    attr_accessor :node
    attr_accessor :left_child
    attr_accessor :right_child
    attr_accessor :parent
    attr_accessor :depth

    def initialize
      @node = nil
      @left_child = nil
      @right_child = nil
      @parent = nil
      @depth = nil
    end

    def display_tree
      "w/hash: #{(self.hash % 1000)}"
    end

    def display(indent=35, height=1)
      height += 1
      indentation_shift = 5
      left_indent = indent - indentation_shift
      right_indent = indent + indentation_shift
      if @left_child && @right_child
        print "#{' '*left_indent}L(d=#{height},d=#{left_child.depth}) "+
          "#{left_child.node.display_node}"
        print "#{' '*(indentation_shift*2)}R(d=#{height},d=#{right_child.depth}) "+
          "#{right_child.node.display_node}\n"
        @left_child.display(left_indent, height)
        @right_child.display(indentation_shift*2, height)
      elsif @left_child && @right_child == nil
        puts "#{' '*left_indent}L(d=#{height},d=#{left_child.depth}) "+
          "#{left_child.node.display_node}"
        @left_child.display(left_indent, height)
      elsif @left_child == nil && @right_child
        puts "#{' '*(right_indent)}R(d=#{height},d=#{right_child.depth}) "+
          "#{right_child.node.display_node}"
        @right_child.display(right_indent, height)
      end
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\ndepth: #{self.depth}"
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
        self.depth = 1 if self.parent == nil
        puts "Tree at depth #{self.depth} inserted node #{node.display_node} into BST"
      elsif node.data < @node.data
        if @left_child == nil
          @left_child = Tree.new
          @left_child.parent = self
          @left_child.depth = self.depth + 1 if self.depth
        end
        @left_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at depth #{self.depth} "+
             "was traversed-left towards node #{@left_child.node.display_node}"
      elsif node.data > @node.data
        if @right_child == nil
          @right_child =Tree.new
          @right_child.parent = self
          @right_child.depth = self.depth + 1 if self.depth
        end
        @right_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at depth #{self.depth} "+
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

    def update_depth(d)
      @depth = d
      #@depth = d
      new_depth = d + 1
      puts "new depth: #{@depth}"
      if @left_child
        @left_child.update_depth(new_depth)
      end
      if @right_child
        @right_child.update_depth(new_depth)
      end
    end

    def update_parent(parent=nil)
      @parent = parent
      puts "new parent: #{@parent}"
      if @parent && @parent.node
        puts "new parent.node: #{@parent.node}"
      end
      if @left_child
        @left_child.update_parent(self)
      end
      if @right_child
        @right_child.update_parent(self)
      end
    end
  end

  def debugging
    LOG_LEVEL == LOG_LEVEL_DEBUG
  end

  def info
    LOG_LEVEL == LOG_LEVEL_INFO
  end

  def quiet
    LOG_LEVEL == LOG_LEVEL_NONE
  end

  def log(msg, label='')
    if debugging
      print "-"*20
      print label
      print "-"*20
      print "\n"
      print "#{msg}\n" if msg
    end
  end

  def log_tree(right, left)
    if debugging
      print "left half"
      print "-"*20
      print "\n"
      print "#{right}\n"

      print " "*20
      print "right half"
      print "-"*20
      print "\n"
      print " "*20
      print "#{left}\n"
    end
  end
end
