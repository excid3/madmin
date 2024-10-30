module Madmin
  class Menu
    def initialize
      @children = {}
    end

    def reset
      @children = {}
    end

    def before_render(&block)
      if block_given?
        @before_render = block
      else
        @before_render
      end
    end

    def render(&block)
      instance_eval(&@before_render) if @before_render

      # Ensure all the resources have been added to the menu
      Madmin.resources.each do |resource|
        next if resource.menu_options == false
        add resource.menu_options
      end

      items.each(&block)
    end

    module Node
      def add(options)
        options = options.dup

        if (parent = options.delete(:parent))
          @children[parent] ||= Item.new(label: parent)
          @children[parent].add options
        else
          item = Item.new(**options)
          @children[item.label] = item
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

    include Node

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
  end
end
