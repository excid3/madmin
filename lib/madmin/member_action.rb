module Madmin
  # Wraps a member action block along with its options so views can decide
  # where to render it. Responds to `to_proc` and `call` so it can be used
  # anywhere the raw block was.
  class MemberAction
    attr_reader :block

    def initialize(collection: false, &block)
      @collection = collection
      @block = block
    end

    def collection? = @collection

    def call(*args, &blk) = block.call(*args, &blk)

    def to_proc = block
  end
end
