# Acorn Plugin Enabler for Ruby/RubyCocoa

While writing plugins in Ruby seems like an awesome idea, the plugin to enable
this all to work uses RubyCocoa, which has apparently been superseded and this
is probably a good thing, since it did unholy things to the Objective-C runtime
and would frequently cause Acorn to crash.  But, we're going to leave this hear
for historical purposes, and maybe someday someone will redo it with a better
bridge.

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
