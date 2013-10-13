class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.text :obs_date_desc
      t.string :condition
      t.float :hours_until_next_lowtide
      t.integer :condition_code
      t.float :wind_mph
      t.float :wind_gust_mph
      t.float :temp
      t.float :wind_chill
      t.datetime :next_low_tide
      t.integer :weather_score
      t.integer :tide_score
      t.boolean :observed
      t.integer :go_funston
      t.timestamps
    end
  end
end
