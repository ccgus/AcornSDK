//
//  Created by August Mueller on 11/14/26.
//  Copyright 2026 Flying Meat Inc.. All rights reserved.
//

import Cocoa
import QuartzCore

@objc(SPGrayscalePlugin)
class SPGrayscalePlugin: NSObject, ACPlugin {

    @objc class func plugin() -> Any {
        return SPGrayscalePlugin()
    }

    func willRegister(_ pluginManager: ACPluginManager) {
        pluginManager.addFilterMenuTitle("Convert to Grayscale",
                                         withSuperMenuTitle: "Color Effect",
                                         target: self,
                                         action: #selector(convert(_:userObject:)),
                                         keyEquivalent: "",
                                         keyEquivalentModifierMask: 0,
                                         userObject: nil)
    }

    func didRegister() {
    }

    @objc func convert(_ image: CIImage, userObject: Any?) -> CIImage? {
        let filter = CIFilter(name: "CIColorMonochrome", parameters: ["inputImage": image])
        filter?.setDefaults()
        filter?.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5), forKey: "inputColor")
        filter?.setValue(NSNumber(value: 1.0), forKey: "inputIntensity")
        return filter?.value(forKey: "outputImage") as? CIImage
    }

    func works(onShapeLayers userObject: Any) -> NSNumber {
        return NSNumber(value: false)
    }

    func validate(for layer: ACLayer) -> NSNumber {
        if layer.layerType() == Int32(ACBitmapLayer) {
            return NSNumber(value: true)
        }
        return NSNumber(value: false)
    }
}
