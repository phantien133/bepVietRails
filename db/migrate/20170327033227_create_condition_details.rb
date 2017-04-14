class CreateConditionDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :condition_details do |t|
      t.references :condition, null: false
      t.string :value
      t.timestamps
    end
    add_index :condition_details, [:condition_id, :value], unique: true
  end
end
