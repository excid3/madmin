class AddHabtmModel < ActiveRecord::Migration[6.1]
  def change
    create_table :user_habtms do |t|
      t.belongs_to :user
      t.belongs_to :habtm
    end

    create_table :habtms do |t|
      t.string :name
    end
  end
end
