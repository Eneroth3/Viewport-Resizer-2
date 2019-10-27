module Eneroth
  module ViewportResizer2
    Sketchup.require "#{PLUGIN_ROOT}/pick_ratio.rb"
    Sketchup.require "#{PLUGIN_ROOT}/viewport.rb"

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

      # Private

      def self.attach_callbacks
        @dialog.add_action_callback("ready") { update_dialog_fields }
        # TODO: Minimize window while using tool.
        @dialog.add_action_callback("pick_ratio") { PickRatio.pick_ratio }
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

      def self.update_dialog_fields
        js = "set_values("\
          "#{Sketchup.active_model.active_view.vpwidth},"\
          "#{Sketchup.active_model.active_view.vpheight},"\
          "#{View.aspect_ratio});"
        # TODO: Format ratio nicely. Localize decimal point. Show 2 decimals.
        # Prepend ~ if not exact. When parsing, keep current value if form field
        # value starts with ~.
        @dialog.execute_script(js)
      end
      private_class_method :update_dialog_fields

      # TODO: Read values onchange.
      # TODO: Honor "window size" checkbox.
      # TODO: Implement ratio lock.
      # TODO: update_dialog_fields from observer on view change.
    end
  end
end
