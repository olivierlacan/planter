class CreatePlantImports < ActiveRecord::Migration[6.0]
  def change
    create_table :plant_imports do |t|
      t.string :name
      t.string :botanical_name
      t.string :days_to_maturity
      t.string :family
      t.string :native
      t.string :hardiness
      t.string :plant_dimensions
      t.string :variety_information
      t.string :type
      t.string :when_to_sow_outside
      t.string :when_to_start_inside
      t.string :days_to_emerge
      t.string :seed_depth
      t.string :seed_spacing
      t.string :row_spacing
      t.string :thinning
      t.string :harvesting
      t.string :learn_more
      t.string :url

      t.timestamps
    end
  end
end
