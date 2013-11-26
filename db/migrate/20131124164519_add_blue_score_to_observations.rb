class AddBlueScoreToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :blue_score, :integer
  end
end
