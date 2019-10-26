module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/picker"

    # Tool for picking entity or two points, later used to define a ratio.
    #
    # @yieldparam points_or_entity
    #   [Array<(Geom::Point3d, Geom::Poin3d>), Sketchup::Drawingelement]
    #
    # @example
    #   RatioPickTool.activate { |callback| p callback }
    class RatioPickTool
      include Picker

      # TODO: Add status texts.
      # "Pick entity or first corner."
      # "Pick second corner. Esc = Drop first corner."
      # REVIEW: Extract logic for whether in first_pick or second_pick mode?

      def self.activate(&callback)
        tool = new(&callback)
        # Push tool so it can later be popped.
        Sketchup.active_model.tools.push_tool(tool)
      end

      def initialize(&callback)
        @callback = callback
        @first_point = nil
        @ip = Sketchup::InputPoint.new
      end

      def activate
        Sketchup.active_model.selection.clear
      end

      def deactivate(view)
        view.invalidate
      end

      def draw(view)
        if @ip.vertex
          @ip.draw(view)
          view.tooltip = @ip.tooltip
        end

        # TODO: Set tooltip from selected entity if any.
        # TODO: Draw selection-like box from @first_point to ip if @first_point
      end

      # TODO: Esc -> drop @first_point

      def onMouseMove(_flags, x, y, view)
        Sketchup.active_model.selection.clear

        @ip.pick(view, x, y)
        view.invalidate
        return if @ip.vertex
        return if @first_point

        try_pick_entity(x, y, view)
      end

      def onLButtonDown(*_)
        if @ip.vertex
          pick_point(@ip.vertex.position)
        elsif !Sketchup.active_model.selection.empty?
          apply(Sketchup.active_model.selection.first)
        end
      end

      private

      def pick_point(point)
        @first_point ? apply(point) : @first_point = point
      end

      def apply(point_or_entity)
        Sketchup.active_model.tools.pop_tool
        @callback.call(callback_param(point_or_entity))
      end

      def callback_param(point_or_entity)
        return point_or_entity unless point_or_entity.is_a?(Geom::Point3d)

        [@first_point, point_or_entity]
      end
    end
  end
end
