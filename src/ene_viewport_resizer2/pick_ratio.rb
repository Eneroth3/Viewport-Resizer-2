module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/pick_ratio_tool"
    # TODO: Wrap in extension!
    require "D:/Sketchup Plugins/Working Dir/View Lib/zoom.rb"

    module PickRatio
      # Let user pick aspect ratio from view.
      #
      # @return [void]
      def self.pick_aspect_ratio
       PickRatioTool.activate do |points_or_entity|
          View.reset_aspect_ratio
          ratio = zoom_to(points_or_entity)

          # Memorize view dimensions before changing viewport aspect ratio.
          view_x = self.view_x
          view_y = self.view_y
          aspect_ratio_ratio = ratio / View.aspect_ratio

          Viewport.ratio = ratio

          # Retain either view width/fov_h or height/fov_v depending on whether
          # content zoomed to fills view vertically or horizontally.
          aspect_ratio_ratio > 1 ? (self.view_x = view_x) : (self.view_y = view_y)
        end
      end

      # Private

      # REVIEW: Move x and y dimension getter setter to View?
      def self.view
        Sketchup.active_model.active_view
      end

      def self.view_x
        view.camera.perspective? ? View.fov_h : View.width
      end

      def self.view_x=(view_x)
        view.camera.perspective? ? View.set_fov_h(view_x) : View.set_width(view_x)
      end

      def self.view_y
        view.camera.perspective? ? View.fov_v : View.height
      end

      def self.view_y=(view_y)
        view.camera.perspective? ? View.set_fov_v(view_y) : View.set_height(view_y)
      end
      # TODO: Make private

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
