class AddSunriseSunsetToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :sunrise, :datetime
    add_column :observations, :sunset, :datetime
    add_column :observations, :is_park_closed, :bool
  end
end
