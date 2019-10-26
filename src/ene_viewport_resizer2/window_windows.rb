require "Win32API"

module Eneroth
  module ViewportResizer2
    # Resize window on Windows.
    module WindowWindows
      # TODO: Make these constants private.
      GetAncestor = Win32API.new("user32.dll", "GetAncestor",  "LI", "I")
      GetActiveWindow = Win32API.new("user32.dll", "GetActiveWindow", "", "L")
      GetWindowRect = Win32API.new("user32.dll", "GetWindowRect", "LP", "I")
      ShowWindow = Win32API.new("user32.dll", "ShowWindow", "LI", "I")
      MoveWindow = Win32API.new("user32.dll", "MoveWindow", "LIIIII", "I")

      GA_ROOTOWNER = 3
      SW_RESTORE = 9
      SW_MAXIMIZE = 3

      # Maximize window.
      #
      # @return [void]
      def self.maximize
        ShowWindow.call(window, SW_MAXIMIZE)
      end

      # Get window size.
      #
      # @return [Array<(Integer, Integer)>]
      #   Width and height.
      def self.size
        left, top, right, bottom = rectangle

        [right - left, bottom - top]
      end

      # "Restore" window, i.e. "de-maximize" it.
      #
      # @return [void]
      def self.restore
        ShowWindow.call(window, SW_RESTORE)
      end

      # Set window size.
      #
      # @param width [Integer]
      # @param height [Integer]
      #
      # @return [void]
      def self.resize(width, height)
        restore

        left, top, _, _ = rectangle
        MoveWindow.call(window, left, top, width, height, 1)
      end

      # Private
      # TODO: Mark as private

      # Get window position.
      #
      # @return [Array<(Integer, Integer, Integer, Integer)>]
      #   Left, top, right and bottom.
      def self.rectangle
        rect = [0, 0, 0, 0].pack("L*")
        GetWindowRect.call(window, rect)

        rect.unpack("L*").map { |e| [e].pack("L").unpack("l").first }
      end

      # Get reference to SketchUp window.
      #
      # @return [Integer]
      def self.window
        # May be Ruby console or other sub-window.
        window = GetActiveWindow.call

        GetAncestor.call(window, GA_ROOTOWNER)
      end
    end
  end
end
