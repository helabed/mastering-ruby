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


RSpec.describe 'BinarySearchTree (BST) testing - iteration last' do
  it 'should search for an element stored in BST' do
    total_num_of_items = 15
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|
        item_to_search_for     = SecureRandom.random_number(randomness_range)
        item_to_traverse_from  = SecureRandom.random_number(randomness_range)
        item_to_delete         = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for    # adds it because we want to search for it
        rand_array << item_to_traverse_from # adds it because we want to use it
        rand_array << item_to_delete        # adds it because we want to delete it

        rand_array.shuffle!

        puts ""
        puts ""
        bst = BinarySearchTree.new

        # commented line below can be used to override random array above
        # overriding above array/values in case we need to debug/fix failing test, or
        # for quick hard coded testing setup
        #rand_array = [30, 92, 36, 66, 33, 28, 63]
        #rand_array = [ 2, 79, 11, 24, 89, 83, 25, 83, 82]
        #rand_array = [ 99, 2, 79, 11, 24, 89, 83, 25, 83, 82]
        #item_to_search_for = 30
        #item_to_traverse_from = 28
        #item_to_delete = 30

        bst.log rand_array, 'the array'
        bst.insert_into(rand_array)
        bst.display_tree
        sleep 5 if bst.debugging # see tree

        bst.log item_to_search_for, 'Will be searching for'
        found, data = bst.search_for(rand_array, item_to_search_for)
        expect(found).to be true
        expect(data).to eq item_to_search_for

        height = bst.height_of_tree
        expect(height).to be < 30 # random high number

        bst.log item_to_delete, 'Will be deleting'
        bst.display_tree
        sleep 5 if bst.debugging # see tree before deltion
        outcome = bst.delete_from(item_to_delete)
        expect(outcome).to be true
        sleep 10 if bst.debugging # see tree after deletion

        bst.do_right_to_left_leaf_traverse
        bst.do_in_order_traverse
        bst.do_pre_in_order_traverse
        bst.do_post_in_order_traverse

        bst.do_right_to_left_leaf_traverse
        outcome = bst.do_ancestors_traverse(item_to_traverse_from)
        expect(outcome).to be true

        outcome = bst.do_descendants_traverse(item_to_traverse_from)
        expect(outcome).to be true
        bst.display_tree
        bst.log '', 'SUCCESS'
      end
    end
  end
end

class BinarySearchTree
  LOG_LEVEL_DEBUG = 2
  LOG_LEVEL_INFO  = 1
  LOG_LEVEL_NONE  = false
  LOG_LEVEL = LOG_LEVEL_INFO

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
      @root_tree.indent = ROOT_NODE_INDENT
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
      # to see elements being inserted
      display_tree if debugging || info
      sleep 0.25 if debugging || info
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
      log nil, "Displaying Tree"
      @root_tree.display_tree_2D(@root_tree)
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
    if @root_tree
      height = @root_tree.height_of_tree
      if @root_tree && (debugging || info)
        log nil, "Computed Height of Tree is #{height}"
      end
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
    if debugging || info
      log nil, "Ancestors Traversal"
    end
    @root_tree.show_me_ancestors_traverse(@root_tree, Node.new(value))
  end

  def do_descendants_traverse(value)
    if debugging || info
      log nil, "Descendants Traversal"
    end
    @root_tree.show_me_descendants_traverse(@root_tree, Node.new(value))
  end

  #
  #
  # BinarySearchTree::Node
  #
  class Node
    attr_accessor :data
    attr_accessor :display_indent

    def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end

    def initialize(data)
      @data = data
      @display_indent = 0
    end

    def dispose
      @data = nil
      @display_indent = 0
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
      s << "\n  display_indent: #{self.display_indent}"
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
    attr_accessor :node
    attr_accessor :left_child
    attr_accessor :right_child
    attr_accessor :parent
    attr_accessor :height
    attr_accessor :indent

   def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end
   def info;      LOG_LEVEL == LOG_LEVEL_INFO;  end

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

    # declaring these here, close to where they are being used
    BinarySearchTree::ROOT_NODE_INDENT = 35
    INDENT_DECAY      = 2.10
    TREE_LIMB_INDENT  = 12 # keep this always even so that we can divide by 2
    NODE_DATA_SIZE    = 2
    NODE_DATA_PADDING = 1
    LEFT_NODE_INDENT  = 4
    RIGHT_NODE_INDENT = 4
    NUM_OF_DASHES = 8

    def display_tree_2D(*root)
      rt = root[0]
      height = rt.height_of_tree if rt
      puts ""
      levels_and_nodes = {}
      height.times do |h|
        level = h+1
        levels_and_nodes[level] = []
        descendants_traverse(rt, rt.node) do |t|
          if t.height == level
            levels_and_nodes[level] << t
          end
        end
      end
      # add root
      levels_and_nodes[1] << rt

      boxes_array = []
      boxes_array[0] = []

      slashes_array = []
      slashes_array[0] = []

      slashes_above_array = []
      slashes_above_array[0] = []

      n_size =  NODE_DATA_SIZE
      n_padd =  NODE_DATA_PADDING
      lp_char = ' ' #'L' # ' '
      rp_char = ' ' #'R' # ' '
      mp_char = ' ' #'M' # ' '

      levels_and_nodes.each_pair do |level, trees|
        puts "Level #{level}: #{trees.map {|t| t.node.data}}"  if debugging

        trees.each_with_index {|t, i|
          puts "tree at index[#{i}] has indent: #{t.indent}"   if debugging
        }

        accumulator = ''
        boxes = []
        slashes = []
        slashes_above = []
        trees.each_with_index {|t, i|
          if i == 0
            left_side_padding = t.indent - (n_size/2).ceil - n_padd
            left_side_padding = 0 if left_side_padding < 0
            l_box = lp_char*left_side_padding
            accumulator << l_box
            slashes << [l_box]
            if level == 2 && t.parent.left_child == nil # our left sibling is nil
              # special treatment for second level to pretty it up
              l_padding = left_side_padding - NUM_OF_DASHES
              l_padding = 0 if l_padding < 0
              l_box_above = lp_char*l_padding
              slashes_above << [l_box_above]
            else
              slashes_above << [l_box]   if level > 1
            end
            boxes << [l_box]
          end
          data_size = n_padd + n_size + n_padd
          data_box = ' '*n_padd + t.node.data.to_s + ' '*n_padd

          if  t.right_child && t.left_child                  # t has both children
            slashes <<   '/  \\'
          elsif  t.left_child                                # t has a left child
            slashes <<   '/ ' + ' '*n_padd + ' '*n_padd
          elsif  t.right_child                               # t has a left child
            slashes << ' '*n_padd + ' '*n_padd +  ' \\'
          elsif  t.right_child == nil && t.left_child == nil # t has no children
            slashes << ' '*n_padd +  '~~' + ' '*n_padd
          end

          if level > 2  # don't do it for root node
            if  t.parent && t.parent.right_child == t          # t is the right child
              slashes_above <<  '\\ ' + ' '*n_padd + ' '*n_padd
            elsif  t.parent && t.parent.left_child == t        # t is the left child
              slashes_above <<  ' '*n_padd + ' '*n_padd + ' /'
            end
          elsif level == 2  # special treatment for second level to pretty it up
            if  t.parent && t.parent.right_child == t          # t is the right child
              slashes_above <<  '--------\\ ' + ' '*n_padd + ' '*n_padd
            elsif  t.parent && t.parent.left_child == t        # t is the left child
              slashes_above <<  ' '*n_padd + ' '*n_padd + ' /--------'
            end
          end

          accumulator << data_box
          boxes << [data_box]
          if trees.size-1 > 0 && i < trees.size-1
            middle_padding = trees[i+1].indent - t.indent - n_padd*4
            if level == 2  # special treatment for second level to pretty it up
              # to allow for /-------- -------\
              middle_padding_4_slashes_above = middle_padding - NUM_OF_DASHES*2
              middle_padding_4_slashes_above = 0 if middle_padding_4_slashes_above < 0
            end
            middle_padding = 0 if middle_padding < 0
            m_box = mp_char*middle_padding
            if level == 2  # special treatment for second level to pretty it up
              m_box_above = mp_char*middle_padding_4_slashes_above
            end
            accumulator << m_box
            boxes << [m_box]
            slashes << m_box
            if level == 2  # special treatment for second level to pretty it up
              slashes_above << m_box_above
            else
              slashes_above << m_box   if level > 1
            end
          end
          if i == trees.size - 1
            right_side_padding = (BinarySearchTree::ROOT_NODE_INDENT*2).floor -
              accumulator.size - (n_size/2).ceil
            right_side_padding = 0 if right_side_padding < 0
            r_box = rp_char*right_side_padding
            accumulator << r_box
            boxes << [r_box]
          end
        }
        boxes_array[level] = boxes
        slashes_array[level] = slashes
        slashes_above_array[level] = slashes_above

        # my beloved measuring stick
        # 1234567890123456789012345678901234567890123456789012345678901234567890

        print "\n"
      end
      puts "The array we just inserted:"
      if debugging || info
        tmp_array = []
        pre_order_traverse do |t|
          tmp_array << t.node.data
        end
        puts "#{tmp_array}"
      end
      boxes_array.each_with_index do |a, i|
        puts slashes_above_array[i].join('')
        puts a.join('')
        puts slashes_array[i].join('')
      end
      puts ""
    end

    def insert_element(node)
      if @node == nil
        @node = node
        puts "Tree at height #{self.height} inserted node #{node.display_node} "+
          "into BST" if debugging
      elsif node.data < @node.data
        if @left_child == nil
          @left_child = Tree.new
          @left_child.parent = self
          @left_child.height = self.height + 1                 if self.height
          more_indent = TREE_LIMB_INDENT - (self.height*INDENT_DECAY).floor
          more_indent = 1 if self.height > 0
          more_indent = 3 if self.height == 1
          @left_child.indent = self.indent - LEFT_NODE_INDENT*more_indent  if self.indent
        end
        @left_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
          "was traversed-left towards node #{@left_child.node.display_node}" if debugging
      elsif node.data > @node.data
        if @right_child == nil
          @right_child = Tree.new
          @right_child.parent = self
          @right_child.height = self.height + 1                  if self.height
          more_indent = TREE_LIMB_INDENT - (self.height*INDENT_DECAY).floor
          more_indent = 1 if self.height > 0
          more_indent = 3 if self.height == 1
          @right_child.indent = self.indent + RIGHT_NODE_INDENT*more_indent  if self.indent
        end
        @right_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
          "was traversed-right towards node #{@right_child.node.display_node}" if debugging
      else
        puts "Node #{node.display_node} is already in tree - ignoring" if debugging
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
      verbose_delete = false
      x           = nil # sub-tree object containing node to be deleted
      x_successor = nil # sub-tree object - in-order successor to x (or predecessor)
      parent      = nil # sub-tree object - parent of x, or soon its successor
      subtree     = nil # sub-tree object - subtree of x before deletion
      found       = false

      found, x, parent = bst_search(tree, item)

      if debugging && verbose_delete
        puts "Element to be deleted was found: #{found}"
        puts "Sub-tree whose node has to be deleted: #{x}"
        puts ""
        puts "Parent of sub-tree whose node has to be deleted: #{parent}"
        puts ""
      end

      return [false, tree] if ! found  # no point in going further

      if x.left_child && x.right_child
        if debugging && verbose_delete
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
        if debugging && verbose_delete
          puts "x_successor: #{x_successor.node.data}"
          puts "parent:      #{parent.node.data}"
          puts "---- descending left ---"
        end
        while x_successor.left_child   # descending left until last left child
          parent      = x_successor
          x_successor = x_successor.left_child
          if debugging && verbose_delete
            puts "x_successor: #{x_successor.node.data}"
            puts "parent:      #{parent.node.data}"
          end
        end

        # move content of x_successor to x, and change x to point
        # to x_successor - which will be deleted after swap
        x.node.data = x_successor.node.data
        x = x_successor

        if debugging && verbose_delete
          puts "x data updated: #{x.node.data}"
        end
      end

      # now proceed with case as if we had 0 or 1 child - book p. 466
      subtree = x.left_child
      subtree ||= x.right_child  # if left child is nil, use right child
      if debugging && verbose_delete
        puts "subtree: #{subtree}"
        puts ""
      end

      if parent == nil
        # root is being deleted, the subtree becomes root
        tree = subtree  # changing root tree to be the subtree when returned
        tree.height = 1
        tree.parent = nil
        if debugging && verbose_delete
          puts "root is being deleted subtree is new root(updated values): #{subtree}"
          tree.show_me_descendants_traverse(tree, tree.node)
        end
        tree.descendants_traverse(tree, tree.node) do |t|
          if debugging && verbose_delete
            puts "////"
            puts "inside tree: #{t.node.data}"
            puts "inside tree old height: #{t.height}"
          end
          t.height = t.parent.height+1 if t.parent
          if debugging && verbose_delete
            puts "inside tree new height: #{t.height}"
            puts "////"
          end
        end
      elsif parent.left_child == x
        parent.left_child = subtree
        if parent.left_child  # the subtree could be nil
          parent.left_child.parent = parent
          parent.left_child.height = parent.height+1
          if debugging && verbose_delete
            puts "parent left child gets the subtree(updated values): #{parent.left_child}"
            parent.show_me_descendants_traverse(parent, parent.node)
          end
          parent.descendants_traverse(parent, parent.node) do |t|
            if debugging && verbose_delete
              puts "////"
              puts "inside tree: #{t.node.data}"
              puts "inside tree old height: #{t.height}"
            end
            t.height = t.parent.height+1
            if debugging && verbose_delete
               puts "inside tree new height: #{t.height}"
               puts "////"
            end
          end
        end
      else
        parent.right_child = subtree
        if parent.right_child  # the subtree could be nil
          parent.right_child.parent = parent
          parent.right_child.height = parent.height+1
          if debugging && verbose_delete
            puts "parent right child gets the subtree(updated values): #{parent.right_child}"
            parent.show_me_descendants_traverse(parent, parent.node)
          end
          parent.descendants_traverse(parent, parent.node) do |t|
            if debugging && verbose_delete
              puts "////"
              puts "inside tree: #{t.node.data}"
              puts "inside tree old height: #{t.height}"
            end
            t.height = t.parent.height+1
            if debugging && verbose_delete
              puts "inside tree new height: #{t.height}"
              puts "////"
            end
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
      if debugging || info
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
      else
        return true
      end
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
      if debugging || info
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
      else
        return true
      end
    end
  end
  # End of BinarySearchTree::Tree
end
