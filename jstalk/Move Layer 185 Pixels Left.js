/*
ACScriptMenuTitle = Move Layer 185 Pixels Left
ACShortcutKey = 
ACShortcutMask = 

How to install this plugin:
1) Choose Acorn's Help ▸ Open Acorn's App Support Folder menu item.
2) Place this script in the Plug-Ins folder (and make sure it ends with .js)
3) Restart Acorn.  The plugin will now show up in the Filter menu.

*/

function main(image, doc, layer) {
    
    var fo = layer.frameOrigin()
    fo.x -= 185;
    layer.setFrameOrigin(fo);
}

