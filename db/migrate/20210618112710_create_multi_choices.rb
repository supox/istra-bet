class CreateMultiChoices < ActiveRecord::Migration[6.1]
  def change
    create_table :multi_choices do |t|
      t.string :description, null: false
      t.text :options, default: [].to_yaml
      t.integer :bet_points
      t.text :result, default: nil
      t.references :round, foreign_key: true

      t.timestamps
    end
  end
end
