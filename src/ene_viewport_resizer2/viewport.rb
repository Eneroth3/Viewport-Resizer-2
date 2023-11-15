module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/window.rb"

    # Functionality related to SketchUp viewport.
    module Viewport
      # Get viewport aspect ratio.
      #
      # @return [Float]
      def self.ratio
        width, height = size

        width.to_f / height
      end

      # Set viewport aspect ratio.
      #
      # @param ratio [Numeric]
      #
      # @return [void]
      def self.ratio=(ratio)
        Window.restore

        # First try to extend the smaller of the two sides.
        # Assume OS wont let Window get bigger than available space on screen.
        width, height = size
        ratio_ratio = ratio / self.ratio
        ratio_ratio > 1 ? width = height * ratio : height = width / ratio
        resize(width.to_i, height.to_i)
        return if self.ratio == ratio

        # If desired ratio hasn't been reached, try reducing the large side.
        ratio_ratio = ratio / self.ratio
        ratio_ratio < 1 ? width *= ratio_ratio : height /= ratio_ratio
        resize(width.to_i, height.to_i)
      end

      # Set viewport size.
      #
      # @param width [Integer]
      # @param height [Integer]
      #
      # @return void
      def self.resize(width, height)
        if Sketchup.respond_to?(:resize_viewport)
          Sketchup.resize_viewport(Sketchup.active_model, width, height)
          return
        end

        # Repeat a few times as changing window size can move around toolbar and
        # make window chrome thicker.
        3.times do
          chrome_size = Window.size.zip(size).map { |w, v| w - v }
          window_size = [width, height].zip(chrome_size).map { |v, c| v + c }

          break if window_size == Window.size

          Window.resize(*window_size)
        end
      end

      # Get viewport size.
      #
      # @return [Array<(Integer, Integer)>]
      #   Width and height.
      def self.size
        view = Sketchup.active_model.active_view

        [view.vpwidth, view.vpheight]
      end
    end
  end
end
