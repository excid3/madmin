class AddTagsToPosts < ActiveRecord::Migration[8.0]
  # Array columns are PostgreSQL only
  def change
    if connection.adapter_name == "PostgreSQL"
      add_column :posts, :tags, :string, array: true, default: []
    end
  end
end
