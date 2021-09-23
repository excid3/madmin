class AddPreferencesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferences, :text
  end
end
