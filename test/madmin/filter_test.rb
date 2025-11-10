require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test "filters records with all conditions" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "all",
          "conditions" => {
            "0" => {
              "column" => "first_name",
              "operator" => "eq",
              "value" => users(:one).first_name,
              "type" => "string"
            },
            "1" => {
              "column" => "last_name",
              "operator" => "eq",
              "value" => users(:one).last_name,
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters)
    assert_equal [users(:one)], results.to_a
  end

  test "filters records with any match type" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "any",
          "conditions" => {
            "0" => {
              "column" => "first_name",
              "operator" => "eq",
              "value" => users(:one).first_name,
              "type" => "string"
            },
            "1" => {
              "column" => "first_name",
              "operator" => "eq",
              "value" => users(:three).first_name,
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters)
    expected_ids = [users(:one).id, users(:three).id].sort
    assert_equal expected_ids, results.pluck(:id).sort
  end

  test "filters records across multiple groups" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "any",
          "conditions" => {
            "0" => {
              "column" => "first_name",
              "operator" => "eq",
              "value" => users(:one).first_name,
              "type" => "string"
            },
            "1" => {
              "column" => "first_name",
              "operator" => "eq",
              "value" => users(:three).first_name,
              "type" => "string"
            }
          }
        },
        "1" => {
          "match_type" => "all",
          "conditions" => {
            "0" => {
              "column" => "last_name",
              "operator" => "eq",
              "value" => users(:one).last_name,
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters)
    expected_ids = [users(:one).id, users(:three).id].sort
    assert_equal expected_ids, results.pluck(:id).sort
  end

  test "filters records with null operator" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "all",
          "conditions" => {
            "0" => {
              "column" => "token",
              "operator" => "is_null",
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters)
    expected_ids = [users(:one).id, users(:two).id].sort
    assert_equal expected_ids, results.pluck(:id).sort
  end

  test "ignores filters with invalid columns" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "all",
          "conditions" => {
            "0" => {
              "column" => "non_existent",
              "operator" => "eq",
              "value" => "value",
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters)
    assert_equal User.pluck(:id).sort, results.pluck(:id).sort
  end

  # TODO: Revisit how keyword search and filters should interact, right not: filters run first, then search narrows results
  test "keyword search narrows after filters" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "all",
          "conditions" => {
            "0" => {
              "column" => "first_name",
              "operator" => "eq",
              "value" => users(:three).first_name,
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters, query: users(:one).first_name)
    # none results as search term takes precedence
    assert_equal [], results.pluck(:id)
  end

  test "keyword search still respects overlapping filter matches" do
    filters = {
      groups: {
        "0" => {
          "match_type" => "all",
          "conditions" => {
            "0" => {
              "column" => "token",
              "operator" => "is_null",
              "type" => "string"
            }
          }
        }
      }
    }

    results = run_search(filters, query: users(:one).first_name)
    assert_equal [users(:one).id], results.pluck(:id)
  end

  private

  def run_search(filters, query: nil)
    Madmin::Search.new(User.all, UserResource, query, filters).run
  end
end
