module Eneroth
  module ViewportResizer2
    # Wrapper for ViewObserver that attaches the observer to each new model.
    # REVIEW: Make general solution for all observers.
    class ViewNotifier
      @observers ||= Set.new

      # Invoke observer on further view changes.
      #
      # @param observer [Object] See +ViewObserver+ for details.
      #
      # @return [void]
      def self.add_observer(observer)
        @observers.add(observer)
      end

      # Stop observer from being invoked.
      #
      # @param observer [Object] See +ViewObserver+ for details.
      #
      # @return [void]
      def self.remove_observer(observer)
        @observers.delete(observer)
      end

      # @private
      def self.on_view_change(*args)
        @observers.each do |observer|
          observer.onViewChanged(*args) if observer.respond_to?(:onViewChanged)
        end
      end

      # @private
      class ViewObserver < Sketchup::ViewObserver
        def onViewChanged(*args)
          ViewNotifier.on_view_change(*args)
        end
      end

      # @private
      class AppObserver < Sketchup::AppObserver
        VIEW_OBSERVER ||= ViewObserver.new

        def expectsStartupModelNotifications
          true
        end

        def onNewModel(model)
          model.active_view.add_observer(VIEW_OBSERVER)
        end

        def onOpenModel(model)
          model.pages.add_observer(VIEW_OBSERVER)
        end
      end

      unless @loaded
        @loaded = true
        Sketchup.add_observer(AppObserver.new)
      end
    end
  end
end
