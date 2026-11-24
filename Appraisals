appraise "rails-7" do
  gem "rails", "~> 7.0.0"
  gem "sqlite3", "~> 1.4"

  # Ruby 3.4+
  gem "benchmark"
  gem "drb"
  gem "mutex_m"

  # Fixes uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger (NameError)
  gem "concurrent-ruby", "< 1.3.5"

  gem "minitest", "< 6.0.0"
  gem "json", "< 3" # This Rails passes quirks_mode, which json 3 rejects
end

appraise "rails-7-1" do
  gem "rails", "~> 7.1.0"
  gem "sqlite3", "~> 1.4"
  gem "minitest", "< 6.0.0"
  gem "json", "< 3" # This Rails passes quirks_mode, which json 3 rejects
end

appraise "rails-7-2" do
  gem "rails", "~> 7.2.4" # 7.2.4 stops passing quirks_mode, which json 3 rejects
  gem "minitest", "< 6.0.0"
end

appraise "rails-8-0" do
  gem "rails", "~> 8.0.0"
  gem "minitest", "< 6.0.0"
  gem "json", "< 3" # This Rails passes quirks_mode, which json 3 rejects
end

appraise "rails-8-1" do
  gem "rails", "~> 8.1.0"
end

appraise "rails-main" do
  gem "rails", github: "rails/rails"
end

appraise "sprockets" do
  remove_gem "propshaft"
  gem "sprockets-rails"
end

appraise "lexxy" do
  gem "lexxy"
end
