class AddAdminBalanceAndDigestTimeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :balance, :decimal, precision: 10, scale: 2
    add_column :users, :digest_time, :time
  end
end
