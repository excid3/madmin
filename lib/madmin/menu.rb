# frozen_string_literal: true

module Madmin
  # The navigation menu. Items are added from an initializer with `add`, or
  # from a `before_render` block when they need something from the request,
  # and every resource adds itself with its `menu` options.
  #
  # Each render builds the items from scratch, so the menu follows the locale
  # and code reloading without being reset, and rendering changes nothing
  # shared between requests.
  class Menu
    def initialize
      @items = []
      @before_render = nil
    end

    # Adds an item to every render. Takes the same options as a resource's `menu`
    def add(options)
      @items << options.dup
    end

    # A block instance_eval'd on every render before the resources are added.
    # Use `add` inside it for items that depend on the request
    def before_render(&block)
      if block_given?
        @before_render = shareable(block)
      else
        @before_render
      end
    end

    def render(&block)
      tree = Tree.new
      @items.each { |options| tree.add options }
      tree.instance_eval(&@before_render) if @before_render

      # Ensure all the resources have been added to the menu
      Madmin.resources.each do |resource|
        next if resource.menu_options == false
        tree.add resource.menu_options
      end

      tree.items.each(&block)
    end

    module Node
      def add(options)
        options = options.dup

        if (parent = options.delete(:parent))
          @children[parent] ||= Item.new(label: parent)
          @children[parent].add options
        else
          key = options.delete(:key)
          item = Item.new(**options)
          @children[key || item.label] = item
        end
      end

      def items
        @children.values.sort do |a, b|
          result = a.position <=> b.position
          result = a.label <=> b.label if result == 0 # sort alphabetically for the same position
          result
        end
      end
    end

    # The items of a single render
    class Tree
      include Node

      def initialize
        @children = {}
      end
    end

    class Item
      include Node

      attr_reader :label, :url, :position, :parent, :children

      def initialize(label:, url: nil, position: 99, parent: nil, **options)
        @label = label
        @url = url
        @position = position
        @parent = parent
        @if = options.delete(:if)
        @children = {}
      end
    end

    private

    # A proc other Ractors can call, on Ruby 4.0. The block is instance_eval'd,
    # so its self is replaced either way. A block capturing something
    # unshareable, or any block on an earlier Ruby, is kept as it is, which
    # Madmin.ractorize! then reports
    def shareable(block)
      return block unless Ractor.respond_to?(:shareable_proc)

      Ractor.shareable_proc(self: nil, &block)
    rescue Ractor::IsolationError
      block
    end
  end
end
