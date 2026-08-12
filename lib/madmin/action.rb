module Madmin
  # Wraps a member/collection action block along with its options so views can
  # decide where to render it. Responds to `to_proc` and `call` so it can be
  # used anywhere the raw block was.
  class Action
    attr_reader :block

    def initialize(collection: false, &block)
      @collection = collection
      @block = block
    end

    def collection?
      @collection
    end

    def call(*args, &blk)
      block.call(*args, &blk)
    end

    def to_proc
      block
    end
  end
end
