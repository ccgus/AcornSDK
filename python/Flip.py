#!/usr/bin/python
from Foundation import *
from AppKit import *
import time
import os
import os.path

def acornProxy():
    port = "com.flyingmeat.Acorn4.JSTalk"
    
    conn = None
    tries = 0
    
    while ((conn is None) and (tries < 10)):
        conn = NSConnection.connectionWithRegisteredName_host_(port, None)
        tries = tries + 1;
        
        if (not conn):
            print("Waiting for Acorn to launch");
            time.sleep(1)
    
    if (not conn):
        print("Could not find a JSTalk connection")
        return None
    
    return conn.rootProxy()
    
    
# Grab the Acorn DO
acorn = acornProxy();


acorn.setPreference_forKey_(".5", "jpegCompression");

for f in os.listdir("Originals"):
    path = os.path.abspath("Originals/" + f)
    print(path)
    doc = acorn.open_(path);
    doc.flipCanvasWithDirection_("horizontal");
    doc.saveDocument_(None)
    doc.close()
    
    # this is equally valid:
    # newDoc.dataOfType("public.png").writeToFile("/tmp/foo.png") 
    