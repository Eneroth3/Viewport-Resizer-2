require "fiddle/import"

module Eneroth
  module ViewportResizer2
    # SketchUp window functionality on Windows.
    module WindowWindows
      # Maximize window.
      #
      # @return [void]
      def self.maximize
        User32::ShowWindow(window, User32::SW_MAXIMIZE)
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
        User32::ShowWindow(window, User32::SW_RESTORE)
      end

      # Set window size.
      #
      # @param width [Integer]
      # @param height [Integer]
      #
      # @return [void]
      def self.resize(width, height)
        restore
        left, top = rectangle
        User32::MoveWindow(window, left, top, width, height, 1)
      end

      # Private

      # Get window position.
      #
      # @return [Array<(Integer, Integer, Integer, Integer)>]
      #   Left, top, right and bottom.
      def self.rectangle
        rect = [0, 0, 0, 0].pack("L*")
        User32::GetWindowRect(window, rect)

        rect.unpack("L*").map { |e| [e].pack("L").unpack("l").first }
      end
      private_class_method :rectangle

      # Get reference to SketchUp window.
      #
      # @return [Integer]
      def self.window
        # Active Window may be Ruby console or some other window.
        User32::GetAncestor(User32::GetActiveWindow(), User32::GA_ROOTOWNER)
      end
      private_class_method :window

      # User32 functionality on Windows.
      module User32
        extend Fiddle::Importer
        dlload "user32"

        # GetAncestor root owner.
        GA_ROOTOWNER = 3

        # ShowWindow restore.
        SW_RESTORE = 9

        # ShowWindow maximize.
        SW_MAXIMIZE = 3

        typealias "DWORD", "unsigned long"
        typealias "PDWORD", "unsigned long *"
        typealias "DWORD32", "unsigned long"
        typealias "DWORD64", "unsigned long long"
        typealias "WORD", "unsigned short"
        typealias "PWORD", "unsigned short *"
        typealias "BOOL", "int"
        typealias "ATOM", "int"
        typealias "BYTE", "unsigned char"
        typealias "PBYTE", "unsigned char *"
        typealias "UINT", "unsigned int"
        typealias "ULONG", "unsigned long"
        typealias "UCHAR", "unsigned char"
        typealias "HANDLE", "uintptr_t"
        typealias "PHANDLE", "void*"
        typealias "PVOID", "void*"
        typealias "LPCSTR", "char*"
        typealias "LPSTR", "char*"
        typealias "HINSTANCE", "unsigned int"
        typealias "HDC", "unsigned int"
        typealias "HWND", "unsigned int"

        extern "HWND GetAncestor(HWND, UINT)"
        extern "HWND GetActiveWindow()"
        extern "BOOL MoveWindow(HWND, UINT, UINT, UINT, UINT, BOOL)"
        extern "BOOL ShowWindow(HWND, UINT)"
        extern "BOOL GetWindowRect(HWND, LPSTR)" # REVIEW: Correct type?
      end
      private_constant :User32
    end
  end
end
