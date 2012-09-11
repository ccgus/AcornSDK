//
//  Kernelr.h
//  Kernelr
//
//  Created by August Mueller on 10/10/07.
//  Copyright Flying Meat Inc 2007 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "ACPlugin.h"

#import "Kernelr.h"
#import "KernelrKontroler.h"

@interface Kernelr : NSObject <ACPlugin> {
    KernelrKontroler *kontroler;
}

@end
