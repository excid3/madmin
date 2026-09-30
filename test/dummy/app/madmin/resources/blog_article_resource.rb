# Named for the operator ("blog articles"), not the model. There is no
# ArticleResource, so Madmin.resource_for(Article.new) can only get here through
# the `model` declaration.
class BlogArticleResource < Madmin::Resource
  model Article

  attribute :id, form: false
  attribute :title

  menu false
end
