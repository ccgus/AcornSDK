OSX.require_framework 'QuartzCore'

ac_spec(
  :menuTitle    => "Quick Exposure",
  :shortcutKey  => 'j',
  :shortcutMask => [:command, :control] )

ac_action do |image, userObject|
  
  @filter = CIFilter.filterWithName('CIExposureAdjust')
  @filter.setValue_forKey(image, 'inputImage')
  
  @filter.setValue_forKey(NSNumber.numberWithFloat(1.0), 'inputEV')
  
  # this returns it via some sort of ruby magic
  @filter.valueForKey('outputImage')
end
