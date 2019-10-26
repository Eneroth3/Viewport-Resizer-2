module Eneroth
  module ViewportResizer2
    # Mixin module for tools capable of picking (selecting) entities, similar to
    # native Move, Rotate and Scale tool.
    #
    # Override `valid_pick?` in the target class for custom entity validation.
    module Picker
      # Try to pick an entity in model.
      #
      #
      # @param x [Integer] The screen X coordinate where the event occurred.
      # @param y [Integer] The screen Y coordinate where the event occurred.
      # @param view [Sketchup::View] A View object where the method was invoked.
      #
      # @return [nil, Sketchup::Entity]
      def try_pick_entity(x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        entity = ph.best_picked
        selection = Sketchup.active_model.selection
        selection.clear
        return unless entity
        return unless valid_pick?(entity)
        selection.add(entity)

        entity
      end

      # Check whether an entity can be picked. Override this method in target
      # class for a custom check.
      #
      # @param entity [Entity]
      #
      # @return [Boolean]
      def valid_pick?(entity)
        !entity.is_a?(Sketchup::Axes)
      end
    end
  end
end
