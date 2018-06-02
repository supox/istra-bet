class AddUniqueIndexToBets < ActiveRecord::Migration[5.2]
  def change
    add_index :bets, [:game_id, :user_id], unique: true
  end
end
