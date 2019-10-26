module Eneroth
  module ViewportResizer2
    # Shorthand for platform specific Window module.
    Window =
      if Sketchup.platform == :platform_win
        Sketchup.require "#{PLUGIN_ROOT}/window_windows.rb"

        WindowWindows
      else
        Sketchup.require "#{PLUGIN_ROOT}/window_mac.rb"

        WindowMac
      end
  end
end
