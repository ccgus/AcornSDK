# -*- mode:ruby; indent-tabs-mode:nil; coding:utf-8 -*-
#
#  ACRubyPlugin.rb
#  RubyPluginEnabler
#
#  Created by Fujimoto Hisa on 07/02/02.
#  Copyright (c) 2007 FOBJ SYSTEMS. All rights reserved.

require 'osx/cocoa'
require 'ACRubyScript'

class ACRubyPlugin < OSX::NSObject
  include OSX

  def self.logger=(log) @@logger = log end
  def self.loginfo(fmt, *args) @@logger.info(fmt, *args) end
  def self.logerror(err)       @@logger.error(err)       end

  def self.install(enabler)
    if not defined? @@instance then
      @@instance = self.alloc.initWithEnabler(enabler)
    end
  end

  def initWithEnabler(enabler)
    @scripts = []
    @enabler = enabler
    load_scripts
    
    install_menu
    return self
  end
  
  def manager; @enabler.manager end
  
  private

  def loginfo(fmt, *args) ACRubyPlugin.loginfo(fmt, *args) end
  def logerror(err)       ACRubyPlugin.logerror(err)       end

  def load_scripts
    collect_scripts.each do |path|
      begin
        @scripts << ACRubyScript.load(path)
      rescue Exception => err
        logerror(err)
      end
    end
  end
  
  def install_menu
    @scripts.each { |i| i.install_menu(manager) }
  end

  def collect_scripts
    script_pathes.map{|path| Dir["#{path}/*.rb"] }.flatten
  end

  def script_pathes
    [ path_to_user_scripts ]
  end

  def path_to_bundle_scripts
    bundle = OSX::NSBundle.bundleForClass(self.class)
    "#{bundle.resourcePath.to_s}/Script PlugIns"
  end

  def path_to_user_scripts
    path = "~/Library/Application Support/Acorn/Plug-Ins"
    path = File.expand_path(path)
    require 'fileutils'
    FileUtils.mkdir_p(path) if not File.exist?(path)
    return path
  end
end
