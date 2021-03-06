/*
* Copyright ⓒ 2019 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class DefaultInfoBar : Gtk.InfoBar {
    public DefaultInfoBar () {
        Object (
            message_type: Gtk.MessageType.QUESTION,
            show_close_button: true
        );
    }

    construct {
        var settings = new Settings ("com.github.cassidyjames.ephemeral");

        var default_label = new Gtk.Label ("<b>Make privacy a habit.</b> Set Ephemeral as your default browser?\n<small>You can always change this later in <i>System Settings</i> → <i>Applications</i>.</small>");
        default_label.use_markup = true;
        default_label.wrap = true;

        var default_app_info = GLib.AppInfo.get_default_for_type (Ephemeral.CONTENT_TYPES[0], false);
        var app_info = new GLib.DesktopAppInfo (GLib.Application.get_default ().application_id + ".desktop");

        var never_button = new Gtk.Button.with_label ("Never Ask Again");
        never_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        get_content_area ().add (default_label);
        add_action_widget (never_button, Gtk.ResponseType.REJECT);
        add_button ("Set as Default", Gtk.ResponseType.ACCEPT);

        revealed =
            !default_app_info.equal (app_info) &&
            settings.get_boolean ("ask-default") &&
            Ephemeral.instance.ask_default_for_session;

        response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    try {
                        for (int i = 0; i < Ephemeral.CONTENT_TYPES.length; i++) {
                            app_info.set_as_default_for_type (Ephemeral.CONTENT_TYPES[i]);
                        }
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                case Gtk.ResponseType.REJECT:
                    settings.set_boolean ("ask-default", false);
                case Gtk.ResponseType.CLOSE:
                    Ephemeral.instance.ask_default_for_session = false;
                    revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });
    }
}

