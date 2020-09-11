class CreateUserConnectedAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_connected_accounts do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :service

      t.timestamps
    end
  end
end
