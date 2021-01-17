class CreateNumericals < ActiveRecord::Migration[6.1]
  def change
    create_table :numericals do |t|
      t.decimal :decimal
      t.float :float

      t.timestamps
    end
  end
end
