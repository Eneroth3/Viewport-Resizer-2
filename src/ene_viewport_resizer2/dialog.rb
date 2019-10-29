module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/pick_ratio.rb"
    Sketchup.require "#{PLUGIN_ROOT}/viewport.rb"
    Sketchup.require "#{PLUGIN_ROOT}/view_notifier.rb"

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
        set_values
      end

      # Private

      # Decimal separator.
      SEPARATOR = Sketchup::RegionalSettings.decimal_separator
      private_constant :SEPARATOR

      def self.attach_callbacks
        ViewNotifier.add_observer(self)
        @dialog.add_action_callback("ready") { set_values }
        @dialog.add_action_callback("onchange") { |_, values| onchange(values) }
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
          height:          220,
          left:            200,
          top:             100
        )
      end
      private_class_method :create_dialog

      def self.format_ratio(ratio)
        decimals = 2
        rounded = ratio.round(decimals) != ratio

        "#{rounded ? '~' : ''}#{ratio.round(decimals)}".sub('.', SEPARATOR)
      end
      private_class_method :format_ratio

      def self.onchange(values)
        # TODO: Apply values.
        # Debug. Has to be more advanced and probably know what field was
        # changed to properly interpret the values.
        Viewport.resize(values["width"].to_i, values["height"].to_i)

        # REVIEW: Explicitly update other fields, or let observer handle that?
        # TODO: Focus dialog. Windows seem to focus main SU window when resizing
        # it.
      end
      private_class_method :onchange

      def self.parse_ratio(input, old_value)
        # If input value starts with ~, assume user has not edited it, and that
        # existing value should be kept.
        return old_value if input.start_with?("~")

        input.sub(SEPARATOR, ".").to_f
      end
      private_class_method :parse_ratio

      def self.set_values
        values = {
          width:  Sketchup.active_model.active_view.vpwidth,
          height: Sketchup.active_model.active_view.vpheight,
          ratio:  format_ratio(View.aspect_ratio)
        }
        @dialog.execute_script("set_values(#{values.to_json})")
      end
      private_class_method :set_values

      # TODO: Honor "window size" checkbox. Or remove it?
      # TODO: Implement ratio lock.
      # TODO: Focus first field when showing dialog.
    end
  end
end
