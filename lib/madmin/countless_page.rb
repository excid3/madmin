# frozen_string_literal: true

module Madmin
  # A page of results for a relation that was never counted. One row more than
  # the page size is loaded, so it knows whether a next page exists, but not how
  # many pages there are. The pagination partial shows Previous and Next links
  # without page numbers or a total.
  class CountlessPage < Page
    # Rows loaded for this page, up to per_page + 1
    attr_reader :fetched

    def initialize(fetched:, page: 1, per_page: Madmin.per_page, param: :page)
      super(count: nil, page: page, per_page: per_page, param: param)
      @fetched = fetched
    end

    def count
      nil
    end

    def more?
      fetched > per_page
    end

    def resizable?
      page > 1 || fetched > per_page_options.min
    end

    def from
      fetched.zero? ? 0 : offset + 1
    end

    def to
      fetched.zero? ? 0 : offset + [fetched, per_page].min
    end

    def prev
      page - 1 if page > 1
    end

    def next
      page + 1 if more?
    end

    # No page numbers without a total
    def series(slots: SERIES_SLOTS)
      []
    end
  end
end
