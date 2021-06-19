class CreateMultiChoiceBets < ActiveRecord::Migration[6.1]
  def change
    create_table :multi_choice_bets do |t|
      t.integer :multi_choice_id
      t.integer :user_id
      t.text :answer

      t.timestamps
    end
  end
end
