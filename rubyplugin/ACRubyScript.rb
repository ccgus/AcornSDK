# -*- mode:ruby; indent-tabs-mode:nil; coding:utf-8 -*-
#
#  ACRubyScript.rb
#  ACRubyPluginEnabler
#
#  Created by Fujimoto Hisa on 07/02/09.
#  Copyright (c) 2007 FOBJ SYSTEMS. All rights reserved.

# typical script example...
#
#   # the menu item specs
#   ac_spec( :menuTitle      => 'do something', # required
#            :superMenuTitle => 'category',     # optional
#            :shortcutKey    => 'j',            # optional
#            :shortcutMask   => [ :shift ] )    # optional (see SHORTCUT_MASKS)
#
#   # the program for the script
#   ac_action do |window_controller|
#     ...
#     OSX.NSRunAlertPanel(window_controller.window.title, "OK", nil, nil, nil)
#     ...
#   end

require 'osx/cocoa'

class ACRubyScript < OSX::NSObject

  # primitive: ac_spec - describe the menu item specs for the script
  def ac_spec(spec)
    @spec = spec
  end

  # primitive: ac_action - descript the action/procedure for the script
  def ac_action(&blk)
    @action = blk
  end

  # syntax-sugar: ac_script - combination of ac_spec and ac_action
  def ac_script(spec, &blk)
    @spec   = spec
    @action = blk
  end
  
  # utility: loginfo, logerror - logging wrapper for NSLog
  def loginfo(fmt, *args) ACRubyPlugin.loginfo(fmt, *args) end
  def logerror(err)       ACRubyPlugin.logerror(err)       end

  SHORTCUT_MASKS = {
    :alpha_shift => OSX::NSAlphaShiftKeyMask,
    :alternate   => OSX::NSAlternateKeyMask,
    :command     => OSX::NSCommandKeyMask,
    :control     => OSX::NSControlKeyMask,
    :function    => OSX::NSFunctionKeyMask,
    :help        => OSX::NSHelpKeyMask,
    :numeric_pad => OSX::NSNumericPadKeyMask,
    :shift       => OSX::NSShiftKeyMask,
  }

  def ACRubyScript.create(spec = nil, &blk)
    script = ACRubyScript.alloc.init
    script.ac_spec(spec)   if spec
    script.ac_action(&blk) if blk
    return script
  end

  def ACRubyScript.load(path)
    return ACRubyScript.alloc.initWithPath(path)
  end

  def ACRubyScript.parse(src)
    return ACRubyScript.alloc.initWithSource(src)
  end

  attr_reader   :selector
    
  %w( menuTitle superMenuTitle shortcutKey ).each do |key|
    define_method(key) { @spec[key.to_sym] }
  end

  def shortcutMask
    mask = @spec[:shortcutMask]
    if mask.is_a? Array then
      mask = mask.inject(0) { |product, key|
        val = if key.is_a?(Integer) 
              then key
              else SHORTCUT_MASKS[key.to_sym] || 0 end
        product + val             # => next product
      }
    end
    return mask.to_i
  end

  def init
    @selector = 'executeWithImage:userObject:'
    @spec   = {}
    @action = nil
    @path = @source = nil
    return self
  end

  def initWithPath(path)
    self.init
    @path = path
    @source = File.read(@path)
    parse!
    return self
  end

  def initWithSource(src)
    self.init
    @source = src
    parse!
    return self
  end
  # savePanelDidEnd_returnCode_contextInfo(savePanel, returnCode, windowController)
  def executeWithImage_userObject(image, userObject)
    parse!
    @action.call(image, userObject)
  end
  objc_method :executeWithImage_userObject, [:id, :id, :id]

  def install_menu(manager)
    if self.menuTitle then
     # addPluginsMenuTitle:withSuperMenuTitle:target:action:keyEquivalent:keyEquivalentModifierMask:userObject:
     
      manager.objc_send(  :addFilterMenuTitle, self.menuTitle,
                          :withSuperMenuTitle, self.superMenuTitle,
                                      :target, self,
                                      :action, self.selector,
                               :keyEquivalent, self.shortcutKey,
                   :keyEquivalentModifierMask, self.shortcutMask,
                                  :userObject, self )
    end
  end

  private

  def parse!
    name = @path || self.to_s
    if @path then
      @source = File.read(@path) 
      @spec   = {}
      @action = nil
    end
    if @source && @action.nil? then
      instance_eval(@source, name, 1) # => invoke v_pscript
    end
  end
end
