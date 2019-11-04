module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/pick_ratio.rb"
    Sketchup.require "#{PLUGIN_ROOT}/viewport.rb"
    Sketchup.require "#{PLUGIN_ROOT}/view_notifier.rb"

    # Dialog window showing view dimensions and controls.
    module Dialog
      # Close viewport resize dialog.
      #
      # @return [void]
      def self.close
        @dialog.close
      end

      # Get SketchUp UI::Command validation proc status for dialog visibility.
      #
      # @return [MF_CHECKED, MF_UNCHECKED]
      def self.command_status
        opened? ? MF_CHECKED : MF_UNCHECKED
      end

      # Get current height.
      #
      # @return [Integer]
      def self.height
        Sketchup.active_model.active_view.vpheight
      end

      # Set height.
      #
      # @param height [#to_i]
      def self.height=(height)
        height = height.to_i
        return if height == self.height
        return if height.zero?

        width = locked_ratio? ? (height * View.aspect_ratio).to_i : self.width
        Viewport.resize(width, height)
      end

      # Get ratio lock state.
      #
      # @return [Boolean]
      def self.locked_ratio?
         Sketchup.read_default(PLUGIN_ID, "locked_ratio", true)
      end

      # Set ratio lock state.
      #
      # @param locked_ratio [Boolean]
      def self.locked_ratio=(locked_ratio)
        Sketchup.write_default(PLUGIN_ID, "locked_ratio", locked_ratio)
      end

      # Show viewport resize dialog.
      #
      # @return [void]
      def self.show
        if @dialog && @dialog.visible?
          @dialog.bring_to_front
        else
          create_dialog unless @dialog
          @dialog.set_url("#{PLUGIN_ROOT}/dialog.html")
          attach_callbacks
          @dialog.show
        end

        nil
      end

      # Get current ratio.
      #
      # @return [String]
      def self.ratio
        ratio = View.aspect_ratio
        decimals = 2
        rounded = ratio.round(decimals) != ratio

        "#{rounded ? '~' : ''}#{ratio.round(decimals)}".sub(".", SEPARATOR)
      end

      # Set ratio.
      #
      # @param ratio [String]
      def self.ratio=(ratio)
        return if ratio == self.ratio
        # REVIEW: Accept values starting with ~ ?
        return if ratio.start_with?("~")

        division = ratio.sub(SEPARATOR, ".").split(/:/).map(&:to_f)
        ratio = division[0] / (division[1] || 1)
        return if ratio.zero?

        Viewport.ratio = ratio
      end

      # Toggle viewport resize dialog.
      #
      # @return [void]
      def self.toggle
        opened? ? close : show
      end

      # Check whether viewport resize dialog is currently opened.
      #
      # @return [Boolean]
      def self.opened?
        !!@dialog && @dialog.visible?
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/ViewObserver.html
      def self.onViewChanged(_view)
        # Only called in 2019.2 on viewport resize.
        update_fields
      end

      # Get width.
      #
      # @return [Integer]
      def self.width
        Sketchup.active_model.active_view.vpwidth
      end

      # Set width.
      #
      # @param width [#to_i]
      def self.width=(width)
        width = width.to_i
        return if width == self.width
        return if height.zero?

        height = locked_ratio? ? (width / View.aspect_ratio).to_i : self.height
        Viewport.resize(width, height)
      end

      # Private

      # Decimal separator.
      SEPARATOR = Sketchup::RegionalSettings.decimal_separator
      private_constant :SEPARATOR

      def self.attach_callbacks
        ViewNotifier.add_observer(self)
        @dialog.add_action_callback("ready") { update_fields }
        @dialog.add_action_callback("width") { |_, v| self.width = v }
        @dialog.add_action_callback("height") { |_, v| self.height = v }
        @dialog.add_action_callback("ratio") { |_, v| self.ratio = v }
        @dialog.add_action_callback("lock") { |_, v| self.locked_ratio = v }
        # TODO: Minimize window while using tool.
        @dialog.add_action_callback("pick_ratio") { PickRatio.pick_ratio }
        @dialog.set_on_closed { ViewNotifier.remove_observer(self) }
      end
      private_class_method :attach_callbacks

      def self.create_dialog
        @dialog = UI::HtmlDialog.new(
          dialog_title:    EXTENSION.name,
          preferences_key: name, # Full module name
          resizable:       false,
          style:           UI::HtmlDialog::STYLE_DIALOG,
          width:           220,
          height:          190,
          left:            200,
          top:             100
        )
      end
      private_class_method :create_dialog

      def self.update_fields
        values = {
          width:  width,
          height: height,
          ratio:  ratio,
          lock:   locked_ratio?
        }
        @dialog.execute_script("update_fields(#{values.to_json})")
      end
      private_class_method :update_fields
    end
  end
end
