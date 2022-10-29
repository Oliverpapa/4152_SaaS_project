class CreateAttractions < ActiveRecord::Migration
  def change
    create_table :attractions do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.float :latitude
      t.float :longitude
      t.integer :recommended_time
      t.float :rating
      t.time :open_time
      t.time :close_time

      t.timestamps null: false
    end
  end
end
