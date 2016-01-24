require_relative "tree_node"
require_relative "trained_node"
require_relative "observed_node"


class SimpleDecisionTree

  attr_accessor :head_node

  def initialize(head_node = TreeNode.new(nil, nil, 0))
    @head_node = head_node
  end

  def add_branch(new_vals, answer, observed)
    node_pointer = @head_node
    add_node = false

    #cycle through each value and figure out where to put it...
    new_vals.each do |val|
      if node_pointer.children.length > 0
        #find a node with the same value as the current node...
        same_val_node = node_pointer.children.detect { |child| child.value == val }

        if same_val_node
          if observed
            if same_val_node.is_a?(ObservedNode)
              node_pointer = same_val_node
            else
              new_observed = ObservedNode.new same_val_node.parent, same_val_node.children, val
              node_pointer.children.delete same_val_node
              node_pointer.children.add new_observed
              node_pointer = new_observed
            end
          else
            node_pointer = same_val_node
          end
        else
          add_node = true
        end
      else
        add_node = true
      end

      if add_node
        if observed
          new_child = ObservedNode.new(node_pointer, nil, val)
        else
          new_child = TrainedNode.new(node_pointer, nil, val)
        end

        node_pointer.children << new_child
        node_pointer = new_child
      end


    end #end loop


    node_pointer.children=node_pointer.children.clear

    if observed
      node_pointer.children << ObservedNode.new(node_pointer, nil, answer)
    else
      node_pointer.children << TrainedNode.new(node_pointer, nil, answer)
    end

  end

  #end class

  def compute(input_vals)
    #start with the head node and work down the tree comparing each value
    node_pointer = @head_node

    input_vals.each do |input_val|
      #get the closest node by value...           
      mapped_nodes = node_pointer.children.map do |child|
        # :node=>child, :diff=>(child.value - inputVal).abs, :observed=>child.class == ObservedNode }
        [child, (child.value - input_val).abs, child.is_a?(ObservedNode) ? 1 : 0]
      end.sort_by { |a| [a[1], !a[2]] }

      node_pointer = mapped_nodes.first[0]

      puts node_pointer.value

    end

    raise "bad tree" unless node_pointer.children.length == 1

    return node_pointer.children.first.value
  end

end
