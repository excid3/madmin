class ChangeIntToBigint < ActiveRecord::Migration[6.1]
  def change
    change_column :active_storage_attachments, :record_id, :bigint
    change_column :active_storage_attachments, :blob_id, :bigint

    change_column :active_storage_variant_records, :blob_id, :bigint

    change_column :user_habtms, :user_id, :bigint
    change_column :user_habtms, :habtm_id, :bigint
  end
end
