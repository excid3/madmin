# A model whose resource is NOT named after it: BlogArticleResource declares
# `model Article`. Exercises Madmin.resource_for's declared-model fallback.
# Rides the posts table so the dummy schema stays untouched.
class Article < ApplicationRecord
  self.table_name = "posts"
end
