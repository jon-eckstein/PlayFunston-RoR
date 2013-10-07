require_relative "tree_node"
require_relative "trained_node"
require_relative "observed_node"


class SimpleDecisionTree
	
	attr_accessor :headNode
		
	def initialize(headNode = TreeNode.new(nil,nil,0))		  
    @headNode = headNode           
  end 
	
	def add_branch(newVals, answer, observed)
     	nodePointer = @headNode
     	addNode = false
     	
     	#cycle through each value and figure out where to put it...
      newVals.each do |val|
        childCount = nodePointer.children.length
        if childCount > 0
            #find a node with the same value as the current node...       
            sameValNode = nodePointer.children.detect { |child| child.value == val  }         
            
            if !sameValNode.nil?              
              if observed
                if sameValNode.class == ObservedNode                  
                  nodePointer = sameValNode
                else
                  newObserved = ObservedNode.new sameValNode.parent, sameValNode.children, val
                  nodePointer.children.delete sameValNode
                  nodePointer.children.add newObserved
                  nodePointer = newObserved 
                end
              else                
                nodePointer = sameValNode                 
              end
            else
              addNode = true
            end                         
        else
          addNode = true
        end    
           
       if addNode
         if observed
           newChild = ObservedNode.new nodePointer,nil,val
         else
           newChild = TrainedNode.new nodePointer,nil,val
         end
         
         nodePointer.children << newChild
         nodePointer = newChild
       end                                         
      
        
      end #end loop	
     	
     	 
      nodePointer.children=nodePointer.children.clear
      
      if (observed)
          nodePointer.children << ObservedNode.new(nodePointer, nil, answer)
      else
          nodePointer.children << TrainedNode.new(nodePointer, nil, answer)
      end
           	     
	end #end class
	
	def compute(inputVals)
	  #start with the head node and work down the tree comparing each value
    nodePointer = @headNode
    
    inputVals.each do |inputVal|
      #get the closest node by value...           
      mappedNodes = nodePointer.children.map do |child|        
            # :node=>child, :diff=>(child.value - inputVal).abs, :observed=>child.class == ObservedNode }
            [child, (child.value - inputVal).abs, (child.class == ObservedNode) ? 1 : 0] 
      end.sort_by{ |a| [a[1],!a[2]] } 
                                        
      nodePointer = mappedNodes.first[0]
      
      puts nodePointer.value
      
    end
    
    raise "bad tree" unless nodePointer.children.length == 1  
             
    return nodePointer.children.first.value  	  
	end
			
end
