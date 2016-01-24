require "singleton"
require_relative "../simpledecisiontree/simple_decision_tree"
#require_relative "../../app/models/observation"


class DecisionTreeService
  include Singleton

  attr :decision_tree

  def initialize()
    @decision_tree = SimpleDecisionTree.new
    train_tree
  end

  def get_decision(observation)
    @decision_tree.compute(observation.tree_values)
  end

  def add_user_observation(observation)
    return if (observation.condition_code == 0 && observation.go_funston == -1)
    return if (observation.condition_code == 2 && observation.go_funston == 1)

    observation.observed = true

    Observations.create!(observation)
  end

  def train_tree
    @observations = Observation.all
    puts "num observations in train tree #{@observations.length}"
    @observations.each do |obs|
      @decision_tree.add_branch(obs.tree_values, obs.go_funston, obs.observed)
    end
  end
end