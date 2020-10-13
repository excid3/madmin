class Madmin::ActiveStorage::BlobsController < Madmin::ResourceController
  def new
    super
    @record.filename = ""
  end
end
