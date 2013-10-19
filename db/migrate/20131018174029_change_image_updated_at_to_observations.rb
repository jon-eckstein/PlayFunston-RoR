class ChangeImageUpdatedAtToObservations < ActiveRecord::Migration
  def change
  	change_column :observations, :image_updated_at, :string
  end
end
