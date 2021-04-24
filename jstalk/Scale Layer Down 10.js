/*

Note: This script requires Acorn 7 or later.

How to install this plugin:
1) Choose Acorn's Help ▸ Open Acorn's App Support Folder menu item.
2) Place this script in the Plug-Ins folder (and make sure it ends with .js)
3) Restart Acorn.  The plugin will now show up in the Filter menu.

*/

function main(image, doc, layer) {
    if (layer.isBitmap()) {
        
        var img = layer.CIImage();
        
        var extent = img.extent();
        
        var f = CIFilter.filterWithName("CILanczosScaleTransform");
        f.setDefaults();
        f.setInputScale(.9);
        f.setInputImage(img);
        
        var result = f.outputImage();
        
        var offset = CGPointMake(extent.size.width * .05, extent.size.height * .05);
        
        result = result.imageByApplyingTransform(CGAffineTransformMakeTranslation(Math.floor(offset.x), Math.floor(offset.y)));
        
        layer.applyCIImageFromFilter(result);
        
    }
}
