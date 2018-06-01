class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :description
      t.string :team1
      t.string :team2
      t.datetime :start_time
      t.integer :bet_points
      t.integer :result, default: 0
      t.references :round, foreign_key: true

      t.timestamps
    end
  end
end
