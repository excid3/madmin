class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.belongs_to :user
      t.string :title
      t.integer :comments_count
      t.json :metadata
      t.integer :state

      t.timestamps
    end
  end
end
