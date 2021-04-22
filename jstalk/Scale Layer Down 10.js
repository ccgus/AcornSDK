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
        
        var f = CIFilter.filterWithName("CILanczosScaleTransform");
        f.setDefaults();
        f.setInputScale(.9);
        f.setInputImage(img);
        
        var result = f.outputImage();
        
        
        layer.applyCIImageFromFilter(result);
        
    }
}
