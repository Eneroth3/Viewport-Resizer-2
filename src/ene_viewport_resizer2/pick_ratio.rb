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
          Viewport.ratio = ratio
          # TODO: Adjust view to perfectly contain desired ratio.
          # Keep either vertical or horizontal dimension based on how desired
          # ratio related to original view ratio.
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
