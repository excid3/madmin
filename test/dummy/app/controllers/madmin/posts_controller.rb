module Madmin
  class PostsController < Madmin::ResourceController
    def draft
      @record.update(state: :draft)
      redirect_to main_app.madmin_post_path(@record)
    end

    def publish
      @record.update(state: :published)
      redirect_to main_app.madmin_post_path(@record)
    end

    def archive
      @record.update(state: :archived)
      redirect_to main_app.madmin_post_path(@record)
    end
  end
end
