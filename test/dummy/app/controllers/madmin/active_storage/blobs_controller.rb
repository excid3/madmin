class Madmin::ActiveStorage::BlobsController < Madmin::ResourceController
  def new
    super
    @record.assign_attributes(
      filename: "",
      byte_size: 0
    )
  end
end
