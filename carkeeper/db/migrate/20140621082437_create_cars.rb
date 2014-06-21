class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :nickname
      t.string :make, null: false
      t.string :model, null: false
      t.integer :rgb_color
      t.integer :year, null: false

      t.timestamps
    end
  end
end
