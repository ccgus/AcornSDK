/*
How to install this plugin:
1) Choose Acorn's Help ▸ Open Acorn's App Support Folder menu item.
2) Place this script in the Plug-Ins folder (and make sure it ends with .js)
3) Restart Acorn.  The plugin will now show up in the Filter menu.
*/

function main(image, doc, layer) {
    
    var savePanel = NSSavePanel.savePanel();
    
    savePanel.setExtensionHidden(false);
    savePanel.setAllowedFileTypes(["public.png"]);
    savePanel.setNameFieldStringValue(`${doc.lastComponentOfFileName()}.png`)
    
    if (savePanel.runModal()) {
        
        var cgimg = doc.newCGImage();
        
        var data = NSMutableData.data();
        var imageDestination = CGImageDestinationCreateWithData(data, "public.png", 1, null);
        
        CGImageDestinationAddImage(imageDestination, cgimg, null);
        CGImageDestinationFinalize(imageDestination);
        
        data.writeToURL_atomically_(savePanel.URL(), true);
        
        CGImageRelease(cgimg);
        
    }
}

