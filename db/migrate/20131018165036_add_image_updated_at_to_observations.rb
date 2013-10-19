class AddImageUpdatedAtToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :image_updated_at, :datetime
  end
end
