class CreatePlants < ActiveRecord::Migration[6.0]
  def change
    create_table :plants do |t|
      t.string :emergence
      t.integer :depth
      t.integer :seed_spacing
      t.integer :row_spacing
      t.integer :grouping
      t.int4range :maturity
      t.string :thinning
      t.boolean :mound

      t.timestamps
    end
  end
end
