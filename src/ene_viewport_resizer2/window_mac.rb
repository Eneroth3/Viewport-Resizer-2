module Eneroth
  module ViewportResizer2
    # Resize window on Mac.
    module WindowMac
      # Maximize window.
      #
      # @return [void]
      def self.maximize
        raise NotImplementedError
      end

      # Get window size.
      #
      # @return [Array<(Integer, Integer)>]
      #   Width and height.
      def self.size
        raise NotImplementedError
      end

      # "Restore" window, i.e. "de-maximize" it.
      #
      # @return [void]
      def self.restore
        raise NotImplementedError
      end

      # Set window size.
      #
      # @param width [Integer]
      # @param height [Integer]
      #
      # @return [void]
      def self.resize(width, height)
        raise NotImplementedError
      end
    end
  end
end
