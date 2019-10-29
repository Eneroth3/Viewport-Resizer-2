module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/viewport.rb"
    Sketchup.require "#{PLUGIN_ROOT}/pick_ratio_tool"
    # See https://github.com/Eneroth3/view.
    Sketchup.require "#{PLUGIN_ROOT}/vendor/view_lib/view"
    Sketchup.require "#{PLUGIN_ROOT}/vendor/view_lib/zoom"

    # User action for aspect picking ratio from model.
    module PickRatio
      # Let user pick aspect ratio from view.
      #
      # @return [void]
      def self.pick_ratio
        PickRatioTool.activate do |points_or_entity|
          View.reset_aspect_ratio
          ratio = zoom_to(points_or_entity)

          # Memorize view dimensions before changing viewport aspect ratio.
          view_x = View.x
          view_y = View.y
          aspect_ratio_ratio = ratio / View.aspect_ratio

          Viewport.ratio = ratio

          # Retain either view width/fov_h or height/fov_v depending on whether
          # content zoomed to fills view vertically or horizontally.
          aspect_ratio_ratio > 1 ? View.set_x(view_x) : View.set_y(view_y)
        end
      end

      # Private

      def self.zoom_to(points_or_entity)
        # REVIEW: Have a single method in Zoom class that takes both points or
        # entities.
        if points_or_entity.is_a?(Sketchup::Entity)
          Zoom.zoom_entities(points_or_entity, padding: 0)
        else
          Zoom.zoom_points(points_or_entity, padding: 0)
        end
      end
      private_class_method :zoom_to
    end
  end
end
