module Madmin
  # Holds the numbers for a single page of results. Knows nothing about the database.
  #
  # Non-ActiveRecord adapters overriding `paginate_collection` can return one of
  # these (or any object responding to the same methods) alongside their records.
  class Page
    SERIES_SLOTS = 7
    PER_PAGE_OPTIONS = [20, 50, 100, 200].freeze

    attr_reader :count, :page, :per_page, :param

    # The page size for a request param. Invalid sizes fall back to the default,
    # and none can exceed the largest option. Sizes passed to Page.new directly
    # aren't capped
    def self.per_page_for(param)
      size = param.to_s.to_i
      size.positive? ? [size, max_per_page].min : Madmin.per_page
    end

    def self.max_per_page
      [PER_PAGE_OPTIONS.max, Madmin.per_page].max
    end

    def initialize(count:, page: 1, per_page: Madmin.per_page, param: :page)
      @count = count.to_i
      @per_page = [per_page.to_i, 1].max
      @page = [page.to_i, 1].max
      @param = param.to_s
    end

    # The param carrying the page size: "per_page", or "posts_per_page" for a "posts_page" param
    def per_page_param
      "#{param.delete_suffix("page")}per_page"
    end

    # Page sizes to offer, always including the default and the current one
    def per_page_options
      (PER_PAGE_OPTIONS | [Madmin.per_page, per_page]).sort
    end

    # Whether a different page size would change what's shown
    def resizable?
      count > per_page_options.min
    end

    def last
      [(count.to_f / per_page).ceil, 1].max
    end

    # Pages past the end are served empty rather than raising or clamping
    def overflow?
      page > last
    end

    def offset
      (page - 1) * per_page
    end

    def from
      (count.zero? || overflow?) ? 0 : offset + 1
    end

    def to
      overflow? ? 0 : [offset + per_page, count].min
    end

    def prev
      [page - 1, last].min if page > 1
    end

    def next
      page + 1 if page < last
    end

    # Page numbers to link to, with :gap where pages are skipped
    #   [1, :gap, 9, 10, 11, :gap, 20]
    def series(slots: SERIES_SLOTS)
      return (1..last).to_a if last <= slots

      start = (page - (slots - 1) / 2).clamp(1, last - slots + 1)
      pages = (start...(start + slots)).to_a
      pages[0] = 1
      pages[1] = :gap unless pages[1] == 2
      pages[-1] = last
      pages[-2] = :gap unless pages[-2] == last - 1
      pages
    end
  end
end
