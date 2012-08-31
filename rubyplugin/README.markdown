# Acorn Plugin Enabler for Ruby/RubyCocoa

Acorn - http://flyingmeat.com/acorn/


typical script example...

  # the menu item specs
  ac_spec( :menuTitle      => 'do something', # required
           :superMenuTitle => 'category',     # optional
           :shortcutKey    => 'j',            # optional
           :shortcutMask   => [ :shift ] )    # optional (see all masks in ACRubyScript.rb)

  # the program for the script
  ac_action do |image, userObject|
    ...
    OSX.NSRunAlertPanel(window_controller.window.title, "OK", nil, nil, nil)
    ...
  end
