class CreateTargetConditions < ActiveRecord::Migration[5.0]
  def change
    create_table :target_conditions do |t|
      t.integer :target_id, null: false
      t.references :condition_detail, null: false
      t.boolean :is_match, default: true
      t.string :type
      t.timestamps
    end
    add_index :target_conditions, [:condition_detail_id, :target_id, :type], unique: true, name: :add_indexarget_condition
  end
end
