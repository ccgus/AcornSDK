# -*- mode:ruby; indent-tabs-mode:nil; coding:utf-8 -*-
#
#  acr_init.rb
#  RubyPluginEnabler
#
#  Created by Fujimoto Hisa on 07/02/02. (Originally for VoodooPad)
#  Copyright (c) 2007 FOBJ SYSTEMS. All rights reserved.
#

require 'osx/cocoa'
include OSX
OSX.require_framework 'QuartzCore'
$KCODE = 'utf8'

OSX.init_for_bundle do
  |bdl, enabler, log|
  # bdl     - the bundle related with the 2nd argument of RBBundleInit
  # enabler - the 3rd argument of RBBundleInit (ACRubyPluginEnabler)
  # log     - logger for this block
  # log.info("enabler=%p", enabler.to_s)
  # log.info("enabler.pluginManager=%p", enabler.pluginManager.to_s)

  require 'ACRubyPlugin'
  ACRubyPlugin.logger = log
  ACRubyPlugin.install(enabler)
end
