require 'set'

class TreeNode
  include Comparable
  
  attr_accessor :parent, :children, :value
  
  def initialize(parent, children,value)
    @parent = parent
    @value = value
    unless(children.nil?)      
      @children = Set.new(children.sort)      
    else
      @children = Set.new()
    end
  end
  
  def <=> (other)
    @value <=> other      
  end
end