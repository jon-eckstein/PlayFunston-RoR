class AddHoursUntilNextLowTideDescToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :hours_until_next_low_tide_desc, :string
  end
end
