class AddsSettingsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :settings, :json
  end
end
