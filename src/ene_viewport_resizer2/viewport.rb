module Eneroth
  module ViewportResizer2
    if Sketchup.platform == :platform_win
      Sketchup.require "#{PLUGIN_ROOT}/window_windows.rb"
      Window = WindowWindows
    else
      Sketchup.require "#{PLUGIN_ROOT}/window_mac.rb"
      Window = WindowMac
    end

    module Viewport
      # Set viewport size.
      #
      # @param width [Integer]
      # @param height [Integer]
      #
      # @return void
      def self.resize(width, height)
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
