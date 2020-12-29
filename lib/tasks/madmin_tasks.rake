# desc "Explaining what the task does"
# task :madmin do
#   # Task goes here
# end

namespace :madmin do
  desc "Installs madmin into your app"
  task :install do
    system("#{RbConfig.ruby} ./bin/rails generate madmin:install")
  end
end
