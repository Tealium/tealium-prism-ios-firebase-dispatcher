//
//  FirebaseClassesLoader.m
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 21/09/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

#import "FirebaseClassesLoader.h"

#ifdef SWIFT_PACKAGE
@import TealiumPrismFirebase;
#else
#import <TealiumPrismFirebase/TealiumPrismFirebase-Swift.h>
#endif

@implementation FirebaseClassesLoader

+(void)load {
    [FirebaseAutomaticLoader setup];
}

@end
