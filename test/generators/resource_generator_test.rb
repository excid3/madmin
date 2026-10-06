require "test_helper"
require "generators/madmin/resource/resource_generator"

class ResourceGeneratorTest < Rails::Generators::TestCase
  tests Madmin::Generators::ResourceGenerator
  destination Rails.root.join("tmp/generators")

  setup do
    prepare_destination
    mkdir_p File.join(destination_root, "config")
    File.write File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n"
  end

  test "adds the resource routes with bulk destroy" do
    run_generator ["Post", "--skip"]

    assert_file "config/routes.rb", /resources :posts do\n\s+collection { delete :bulk_destroy }\n\s+end/
  end
end
