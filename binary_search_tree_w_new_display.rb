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
    total_num_of_items = 9
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
      #[1,2,2,3,3,33,113],
      #[0,0,2,113,3],
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|

        item_to_search_for = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for # adds it because we want to search for it
        rand_array.shuffle!

        puts ""
        puts ""
        bst = BinarySearchTree.new
        # overriding above array for quick testing setup
        #rand_array = [30, 92, 36, 66, 33, 63]
        #item_to_search_for = 36
        #rand_array = [54, 93, 94, 10, 54, 40]  # different lines for level 3
        #item_to_search_for = 10
        #rand_array = [20, 95, 52, 12, 71, 4]  # different lines for level 3
        #item_to_search_for = 12
        #rand_array = [40, 59, 4, 98, 98, 51, 15, 83, 92, 3, 19] # one array both lines
        #rand_array << [55, 25, 38, 65, 60, 42, 31, 36, 76, 38, 81, 64, 16, 47, 22]
        #item_to_search_for = 42
        #rand_array = [90, 68, 93, 73, 40, 30, 47, 22, 5, 9]
        #item_to_search_for = 73
        #rand_array = [45, 78, 42, 97, 34, 61, 53, 47, 72, 92]
        #item_to_search_for = 45

        #rand_array = [84, 49, 46, 39, 63, 5, 0, 84, 62, 26]
        #item_to_search_for = 84

#rand_array = [1, 86, 69, 28, 30, 51, 75, 24, 1, 35,45, 78, 42, 97, 34, 61, 53, 47, 72, 92]
#rand_array = [1, 86, 69, 28, 30, 51, 75, 24, 1, 35,45, 92]
rand_array = [86, 69, 28, 30, 51, 75, 24, 1, 35,45, 92]
        #item_to_search_for = 1
        #item_to_search_for = 86
        #item_to_search_for = 24

        item_to_search_for = 30
        item_to_traverse_from = 28

        bst.log rand_array, 'the array'
        bst.log item_to_search_for, 'Will be searching for'
        bst.insert_into(rand_array)
        bst.display_tree
        #found, data = bst.search_for(rand_array, item_to_search_for)
        #expect(found).to be true
        #expect(data).to eq item_to_search_for
        #height = bst.height_of_tree
        #expect(height).to eq(7)
        #bst.do_right_to_left_leaf_traverse

        item_to_delete = 30
        #item_to_delete = 51
        #item_to_delete = 28
        #item_to_delete = 75
        #item_to_delete = 69
        #item_to_delete = 86
        #item_to_delete = 1
        #item_to_delete = 35
        #item_to_delete = 24

        outcome = bst.delete_from(item_to_delete)
        expect(outcome).to be true

        #bst.do_in_order_traverse
        #bst.do_pre_in_order_traverse
        #bst.do_post_in_order_traverse
        height = bst.height_of_tree
        #expect(height).to eq(7)
        #bst.do_right_to_left_leaf_traverse
        #outcome = bst.do_ancestors_traverse(item_to_traverse_from)
        #expect(outcome).to be true
        #outcome = bst.do_descendants_traverse(item_to_traverse_from)
        #expect(outcome).to be true
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
      @root_tree.indent = 23
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
      #display_tree
      #sleep 3
    end
  end

  # search BST for element with 'val'in the BST
  #   original 'arr' provided just for logging/debugging
  def search_for(arr,val)
    if @root_tree
      if debugging || info
        log arr, "Finished Adding array -> BST"
        log '', "Searching BST for -> #{val}"
      end
      found, locator, parent = @root_tree.bst_search(@root_tree, Node.new(val))
      if debugging || info
        if found
          log parent, "Found 'parent' #{parent.node.data} in BST" if (parent && parent.node)
          log locator, "Found 'locator(sub-tree)' for #{locator.node.data}"
        else
          log '', "Did NOT find #{val} in the BST"
        end
      end
      return found, locator.node.data if found
      return found, nil if !found
    end
  end

  # delete element with 'value' from the BST
  def delete_from(value)
    log '', "Attempting to delete #{value} from BST"
    outcome, new_root = @root_tree.delete_element(@root_tree, Node.new(value))
    @root_tree = new_root
    display_tree
    return outcome
  end

  def display_tree
    if @root_tree && (debugging || info)
      #log nil, "Displaying Tree"
      #@root_tree.display(@root_tree)
      log nil, "Displaying Tree Turbo"
      @root_tree.display_tree_turbo(@root_tree)
    end
  end

  def do_in_order_traverse
    if @root_tree && (debugging || info)
      log nil, "In Order Tree Traversal"
      @root_tree.show_me_in_order_traverse(@root_tree)
    end
  end

  def do_pre_in_order_traverse
    if @root_tree && (debugging || info)
      log nil, "Pre Order Tree Traversal"
      @root_tree.show_me_pre_order_traverse(@root_tree)
    end
  end

  def do_post_in_order_traverse
    if @root_tree && (debugging || info)
      log nil, "Post Order Tree Traversal"
      @root_tree.show_me_post_order_traverse(@root_tree)
    end
  end

  def height_of_tree
    if @root_tree && (debugging || info)
      height = @root_tree.height_of_tree
      log nil, "Computed Height of Tree is #{height}"
      height
    end
  end

  def do_right_to_left_leaf_traverse
    if @root_tree && (debugging || info)
      log nil, "Right To Left Leaf Traversal"
      @root_tree.show_me_right_to_left_leaf_traverse(@root_tree)
    end
  end

  def do_ancestors_traverse(value)
    if @root_tree && (debugging || info)
      log nil, "Ancestors Traversal"
      @root_tree.show_me_ancestors_traverse(@root_tree, Node.new(value))
    end
  end

  def do_descendants_traverse(value)
    if @root_tree && (debugging || info)
      log nil, "Descendants Traversal"
      @root_tree.show_me_descendants_traverse(@root_tree, Node.new(value))
    end
  end

  #
  #
  # BinarySearchTree::Node
  #
  class Node
    attr_accessor :data

    def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end

    def initialize(data)
      @data = data
      #puts "Node created with data #{data}" if debugging
    end

    def dispose
      @data = nil
    end

    def display
      puts "Displaying Node with #{data}"
    end

    def display_node
      "#{data}"
    end

    def to_s
      s = ''
      s << "\n  hash: #{(self.hash % 1000)}"
      s << "\n  data: #{self.data}"
      s << "\n  --"
      return s
    end
  end
  # End of BinarySearchTree::Node

  #
  #
  # BinarySearchTree::Tree
  #
  class Tree
    DISPLAY_SHIFT = 3
    attr_accessor :node
    attr_accessor :left_child
    attr_accessor :right_child
    attr_accessor :parent
    attr_accessor :height
    attr_accessor :indent

   def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end

    def initialize
      @node = nil
      @left_child = nil
      @right_child = nil
      @parent = nil
      @height = nil
      @indent = nil
    end

    def dispose
      @node.dispose        if @node
      @left_child.dispose  if @left_child
      @right_child.dispose if @right_child
      @parent.dispose      if @parent
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\nheight: #{self.height}"
      s << "\nindent: #{self.indent}"
      parent = self.parent.node.display_node if self.parent && self.parent.node
      parent ||= 'nil'
      s << "\nparent: #{parent}"
      s << "\nnode: #{self.node.display_node}" if self.node
      if self.left_child && self.left_child.node
        left_child_node = self.left_child.node.display_node
      end
      s << "\nleft_child: #{left_child_node}"
      if self.right_child && self.right_child.node
        right_child_node = self.right_child.node.display_node
      end
      s << "\nright_child: #{right_child_node}"
      s << "\n"
      return s
    end

    def display_tree
      "w/hash: #{(self.hash % 1000)}"
    end

    def display_tree_turbo(*root)
      height = root[0].height_of_tree if root[0]
      puts ""
      levels_and_nodes = {}
      #puts "from display_tree_trubo: #{height} Levels"
      height.times do |h|
        level = h+1
        levels_and_nodes[level] = []
        #puts "nodes on level #{level}:"
        descendants_traverse(root[0], root[0].node) do |t|
          if t.height == level
            #puts "  #{t.node.data}"
            levels_and_nodes[level] << t
          end
        end
      end
      #puts "Levels and nodes"
      levels_char_accumulators_4_nodes = {}
      levels_char_accumulators_4_chars = {}
      levels_and_nodes.each_pair do |l, trees|
        levels_char_accumulators_4_nodes[l] = ''
        levels_char_accumulators_4_chars[l] = ''
        #puts "Level #{l}: #{trees.map {|t| t.node.data}}"
        if l == 1
          rt = root[0]
          if rt
            indentation = ' '*(rt.indent)
            node_data   = rt.node.display_node
            puts "#{indentation}#{node_data}"
            levels_char_accumulators_4_nodes[l] << node_data
            indentation_and_chars = ''
            indentation_and_chars = "#{indentation}/ \\" if rt.left_child  && rt.right_child
            indentation_and_chars = "#{indentation}/"    if rt.left_child  && rt.right_child == nil
            indentation_and_chars = "#{indentation}  \\" if rt.right_child && rt.left_child  == nil
            levels_char_accumulators_4_chars[l] << indentation_and_chars
            puts indentation_and_chars
            #binding.pry
            next;
          end
        end
        trees.each_with_index {|t, i|
          if t.parent && i >= 1
            if t.parent.left_child == t             # t is the left_child
              indentation = ' '*(t.parent.indent-DISPLAY_SHIFT)
              node_data   = t.node.data
              levels_char_accumulators_4_nodes[l] << node_data
              print "#{indentation}#{node_data}"
            elsif t.parent.right_child == t         # t is the right_child
              indentation = ' '*(DISPLAY_SHIFT)
              node_data   = t.node.data
              levels_char_accumulators_4_nodes[l] << node_data
              print "#{indentation}#{node_data}"
            end
          else
            indentation = ' '*(t.indent)
            node_data   = t.node.data
            levels_char_accumulators_4_nodes[l] << node_data
            print "#{indentation}#{node_data}"
          end
        }
        print "\n"
        trees.each_with_index {|t, i|
          if l == 5 && (t.node.data == 51 || t.node.data == 1 )
            #binding.pry
          end
          if t.parent && i >= 1
            print "#{' '*(t.parent.indent-DISPLAY_SHIFT)}/"   if t.parent.left_child == t && t.left_child
            print "#{' '*(t.parent.indent+DISPLAY_SHIFT)} \\" if t.parent.left_child == t && t.right_child
            print "#{' '*(t.indent-DISPLAY_SHIFT)}/"   if t.parent.right_child == t && t.left_child
            print "#{' '*(DISPLAY_SHIFT)}  \\" if t.parent.right_child == t && t.right_child
          elsif i == 0
            print "#{' '*(t.indent)}/ \\"  if t.left_child && t.right_child
            print "#{' '*(t.parent.indent-DISPLAY_SHIFT)}/"     if t.left_child && t.right_child == nil
            print "#{' '*(t.indent)}  \\"  if t.right_child && t.left_child == nil
          end
        }
        print "\n"
      end
      puts ""
    end

    def insert_element(node)
      if @node == nil
        @node = node
        if debugging
          puts "Tree at height #{self.height} inserted node #{node.display_node} into BST"
        end
      elsif node.data < @node.data
        if @left_child == nil
          @left_child = Tree.new
          @left_child.parent = self
          @left_child.height = self.height + 1              if self.height
          @left_child.indent = self.indent - DISPLAY_SHIFT  if self.indent
        end
        @left_child.insert_element(node)
        if debugging
          puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
               "was traversed-left towards node #{@left_child.node.display_node}"
        end
      elsif node.data > @node.data
        if @right_child == nil
          @right_child = Tree.new
          @right_child.parent = self
          @right_child.height = self.height + 1              if self.height
          @right_child.indent = self.indent + DISPLAY_SHIFT  if self.indent
        end
        @right_child.insert_element(node)
        if debugging
          puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
               "was traversed-right towards node #{@right_child.node.display_node}"
        end
      else
        if debugging
          puts "Node #{node.display_node} is already in tree - ignoring"
        end
      end
    end

    # search for 'node' element in 'tree' sub-tree
    #
    # iterative implementation of binary search tree - search
    def bst_search(tree, node)
      locator = tree
      parent = nil
      found = false
      while( !found && locator)
        if node.data < locator.node.data
          # descend left
          parent = locator
          locator = locator.left_child
        elsif node.data > locator.node.data
          # descend right
          parent = locator
          locator = locator.right_child
        else
          found = true
        end
      end
      return found, locator, parent
    end

    # delete 'item' element from 'tree' sub-tree
    #
    # iterative implementation of binary search tree - delete
    # Ref: Advanced Programming in Pascal w/Data Structures(1988)
    #      Larry Nyhoff & Sanford Leestma (pages 466-471)
    # variable names match those in book (as much as possible)
    def delete_element(tree, item)
      x           = nil # sub-tree object containing node to be deleted
      x_successor = nil # sub-tree object - in-order successor to x (or predecessor)
      parent      = nil # sub-tree object - parent of x, or soon its successor
      subtree     = nil # sub-tree object - subtree of x before deletion
      found       = false

      found, x, parent = bst_search(tree, item)

      if false
        puts "Element to be deleted was found: #{found}"
        puts "Sub-tree whose node has to be deleted: #{x}"
        puts ""
        puts "Parent of sub-tree whose node has to be deleted: #{parent}"
        puts ""
      end

      return [false, tree] if ! found  # no point in going further

      if x.left_child && x.right_child
        if false
          puts "item to be deleted #{item.data} has 2 children"
          puts "left_child: #{x.left_child.node.data}"
          puts "right_child: #{x.right_child.node.data}"
          puts ""
        end
        # item to be deleted has 2 children
        # find in-order successor (predecessor) and its parent
        # to do so as per book page 469 - start with right child of x
        # then descend left as far as possible
        x_successor = x.right_child
        parent      = x
        if false
          puts "x_successor: #{x_successor.node.data}"
          puts "parent:      #{parent.node.data}"
          puts "---- descending left ---"
        end
        while x_successor.left_child   # descending left until last left child
          parent      = x_successor
          x_successor = x_successor.left_child
          if false
          puts "x_successor: #{x_successor.node.data}"
          puts "parent:      #{parent.node.data}"
          end
        end
        #puts ""

        # move content of x_successor to x, and change x to point
        # to x_successor - which will be deleted after swap
        x.node.data = x_successor.node.data
        x = x_successor

        #puts "x data updated: #{x.node.data}"
      end

      # now proceed with case as if we had 0 or 1 child - book p. 466
      subtree = x.left_child
      subtree ||= x.right_child  # if left child is nil, use right child
      #puts "subtree: #{subtree}"
      #puts ""

      if parent == nil
        # root is being deleted, the subtree becomes root
        tree = subtree  # changing root tree to be the subtree when returned
        tree.height = 1
        tree.parent = nil
        #puts "root is being deleted subtree is new root(updated values): #{subtree}"
        #tree.show_me_descendants_traverse(tree, tree.node)
        tree.descendants_traverse(tree, tree.node) do |t|
          #puts "////"
          #puts "inside tree: #{t.node.data}"
          #puts "inside tree old height: #{t.height}"
          t.height = t.parent.height+1 if t.parent
          #puts "inside tree new height: #{t.height}"
          #puts "////"
        end
      elsif parent.left_child == x
        parent.left_child = subtree
        if parent.left_child  # the subtree could be nil
          parent.left_child.parent = parent
          parent.left_child.height = parent.height+1
          #puts "parent left child gets the subtree(updated values): #{parent.left_child}"
          #parent.show_me_descendants_traverse(parent, parent.node)
          parent.descendants_traverse(parent, parent.node) do |t|
            #puts "////"
            #puts "inside tree: #{t.node.data}"
            #puts "inside tree old height: #{t.height}"
            t.height = t.parent.height+1
            #puts "inside tree new height: #{t.height}"
            #puts "////"
          end
        end
      else
        parent.right_child = subtree
        if parent.right_child  # the subtree could be nil
          parent.right_child.parent = parent
          parent.right_child.height = parent.height+1
          #puts "parent right child gets the subtree(updated values): #{parent.right_child}"
          #parent.show_me_descendants_traverse(parent, parent.node)
          parent.descendants_traverse(parent, parent.node) do |t|
            #puts "////"
            #puts "inside tree: #{t.node.data}"
            #puts "inside tree old height: #{t.height}"
            t.height = t.parent.height+1
            #puts "inside tree new height: #{t.height}"
            #puts "////"
          end
        end
      end

      x.right_child = nil
      x.left_child  = nil
      x.parent      = nil
      x.node        = nil

      return [true, tree] # tree is always the Root tree, even after old root gets deleted
    end

    def show_me_in_order_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "in order traverse"
      puts "------------------"
      in_order_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def show_me_pre_order_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "pre order traverse"
      puts "------------------"
      pre_order_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def show_me_post_order_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "post order traverse"
      puts "------------------"
      post_order_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def in_order_traverse(&block)
      if self.node
        if self.left_child
          self.left_child.in_order_traverse(&block)
        end
        block.call(self)
        if self.right_child
          self.right_child.in_order_traverse(&block)
        end
      end
    end

    def pre_order_traverse(&block)
      if self.node
        block.call(self)
        if self.left_child
          self.left_child.pre_order_traverse(&block)
        end
        if self.right_child
          self.right_child.pre_order_traverse(&block)
        end
      end
    end

    def post_order_traverse(&block)
      if self.node
        if self.left_child
          self.left_child.post_order_traverse(&block)
        end
        if self.right_child
          self.right_child.post_order_traverse(&block)
        end
        block.call(self)
      end
    end

    def height_of_tree
      left_child_height = 0
      right_child_height = 0

      if self.left_child
        left_child_height = self.left_child.height_of_tree
      else
        left_child_height = 0  # left anchor
      end

      if self.right_child
        right_child_height = self.right_child.height_of_tree
      else
        right_child_height = 0  # right anchor
      end

      if right_child_height >= left_child_height
        return right_child_height + 1
      else
        return left_child_height + 1
      end
    end

    def show_me_right_to_left_leaf_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "right to left leaf traverse"
      puts "------------------"
      right_to_left_leaf_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def right_to_left_leaf_traverse(&block)
      if self.node
        if self.right_child
          self.right_child.right_to_left_leaf_traverse(&block)
        end

        if self.right_child == nil && self.left_child == nil
          block.call(self)
        end

        if self.left_child
          self.left_child.right_to_left_leaf_traverse(&block)
        end
      end
    end

    # Ancestors traverse for 'item' element in 'tree' sub-tree
    #
    # first use search to find the element, then descend to it
    # from Root and print the ancestry nodes
    def ancestors_traverse(tree, item, &block)
      x           = nil # sub-tree object containing node to be located
      parent      = nil # sub-tree object - parent of x, or soon its successor
      found       = false

      found, x, parent = bst_search(tree, item)

      return false if ! found  # no point in going further

      locator     = tree
      parent      = nil
      found       = false

      while( !found && locator)
        if item.data < locator.node.data
          # descend left
          block.call(locator)
          parent = locator
          locator = locator.left_child
        elsif item.data > locator.node.data
          # descend right
          block.call(locator)
          parent = locator
          locator = locator.right_child
        else
          found = true
        end
      end
      return found
    end

    def show_me_ancestors_traverse(tree, item)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "Ancestors traverse starting w/item #{item.data}"
      puts "---------------------------------------"
      success =  ancestors_traverse(tree, item) do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
      return success
    end

    # Descendants traverse for 'item' element in 'tree' sub-tree
    #
    # first use search to find the element/item, then from it
    # do a pre_order_traverse form that node and on.
    def descendants_traverse(tree, item, &block)
      x           = nil # sub-tree object containing node to be located
      parent      = nil # sub-tree object - parent of x, or soon its successor
      found       = false

      found, x, parent = bst_search(tree, item)

      return false if ! found  # no point in going further

      locator     = x     # from the located node

      if locator.left_child
        locator.left_child.pre_order_traverse(&block)
      end

      if locator.right_child
        locator.right_child.pre_order_traverse(&block)
      end

      return found
    end

    def show_me_descendants_traverse(tree, item)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "Descendants traverse starting w/item #{item.data}"
      puts "---------------------------------------"
      success =  descendants_traverse(tree, item) do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
      return success
    end
  end
  # End of BinarySearchTree::Tree
end