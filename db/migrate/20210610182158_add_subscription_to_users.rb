class AddSubscriptionToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :subscription, :boolean, default: true
  end
end
