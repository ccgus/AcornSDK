/*
How to install this plugin:
1) Choose Acorn's Help ▸ Open Acorn's App Support Folder menu item.
2) Place this script in the Plug-Ins folder (and make sure it ends with .js)
3) Restart Acorn. The plugin will now show up in the Filter menu.
*/

// The selectLayer method on Document is a private API, and might change in the future, but it'll be around in Acorn 7 for a while.

function main(image, doc, layer) {
    var bottomLayer = doc.baseGroup().layers().firstObject()
    doc.selectLayer(bottomLayer);
}
