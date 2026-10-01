class AddExternalIdToUsers < ActiveRecord::Migration[8.0]
  # UUID columns are PostgreSQL only
  def change
    if connection.adapter_name == "PostgreSQL"
      add_column :users, :external_id, :uuid
    end
  end
end
