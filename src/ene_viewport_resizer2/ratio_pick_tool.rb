module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/picker"

    # Tool for picking entity or two points, later used to define a ratio.
    #
    # @example
    #   RatioPickTool.activate { |callback| p callback }
    class RatioPickTool
      include Picker

      # Status text for first pick.
      STATUS_FIRST = "Pick entity or first corner.".freeze

      # Status text for second pick (only applies if first pick was a corer).
      STATUS_SECOND = "Pick second corner. Esc = Drop first corner.".freeze

      # Activate a RatioPickerTool object.
      #
      # @yieldparam points_or_entity
      #   [Array<(Geom::Point3d, Geom::Poin3d)>, Sketchup::Drawingelement]
      def self.activate(&callback)
        tool = new(&callback)
        # Push tool so it can later be popped.
        Sketchup.active_model.tools.push_tool(tool)
      end

      # Create RatioPickerTool object.
      #
      # @yieldparam points_or_entity
      #   [Array<(Geom::Point3d, Geom::Poin3d)>, Sketchup::Drawingelement]
      def initialize(&callback)
        @callback = callback
        @first_point = nil
        @ip = Sketchup::InputPoint.new
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def activate
        Sketchup.active_model.selection.clear
        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def deactivate(view)
        view.invalidate
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def draw(view)
        draw_box(@first_point, @ip.position, view) if @first_point
        if @ip.vertex
          @ip.draw(view)
          view.tooltip = @ip.tooltip
        elsif !view.model.selection.empty?
          view.tooltip = entity_name(view.model.selection.first)
        end
      end

      # No getExtents method needed for drawing, as we only draw to viewport in
      # 2D.

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onCancel(_reason, view)
        @first_point = nil
        view.model.selection.clear
        view.invalidate
        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onMouseMove(_flags, x, y, view)
        Sketchup.active_model.selection.clear

        @ip.pick(view, x, y)
        view.invalidate
        return if @ip.vertex
        return if @first_point

        try_pick_entity(x, y, view)
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onLButtonDown(*_args)
        if @ip.vertex || @first_point
          # Pick first point from vertex, or second point from anywhere.
          pick_point(@ip.position)
        elsif !Sketchup.active_model.selection.empty?
          # Pick entity unless first point has already been picked.
          apply(Sketchup.active_model.selection.first)
        end
        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def resume(_view)
        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def suspend(view)
        view.invalidate
      end

      # @api
      # @see https://extensions.sketchup.com/en/content/eneroth-tool-memory
      def ene_tool_cycler_exclude
        true
      end

      private

      def draw_box(corner1, corner2, view)
        corner1 = view.screen_coords(corner1)
        corner2 = view.screen_coords(corner2)

        rectangle = [
          corner1, Geom::Point3d.new(corner1.x, corner2.y, 0),
          corner2, Geom::Point3d.new(corner2.x, corner1.y, 0)
        ]

        view.drawing_color = "Black"
        view.line_stipple = "_"

        view.draw2d(GL_LINE_LOOP, rectangle)
      end

      def entity_name(entity)
        case entity
        when Sketchup::Group
          entity.name
        when Sketchup::ComponentInstance
          entity.name.empty? ? entity.definition.name : entity.name
        else
          # Using typename to get localized name of the entity type.
          entity.typename
        end
      end

      def pick_point(point)
        @first_point ? apply(point) : @first_point = point
      end

      def apply(point_or_entity)
        Sketchup.active_model.tools.pop_tool
        Sketchup.active_model.selection.clear
        @callback.call(callback_param(point_or_entity))
      end

      def callback_param(point_or_entity)
        return point_or_entity unless point_or_entity.is_a?(Geom::Point3d)

        [@first_point, point_or_entity]
      end

      def update_status_text
        Sketchup.status_text = @first_point ? STATUS_SECOND : STATUS_FIRST
      end
    end
  end
end
