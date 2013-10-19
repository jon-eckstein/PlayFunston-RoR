class AddNextHighTideToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :next_high_tide, :datetime
    add_column :observations, :hours_until_next_high_tide, :float
    add_column :observations, :hours_until_next_high_tide_desc, :string
  end
end
