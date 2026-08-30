class AddUsersAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :active, :boolean, default: true
    add_column :users, :balance, :decimal, precision: 10, scale: 2
    add_column :users, :last_login_time, :time

    add_reference :numericals, :user, foreign_key: true
  end
end
