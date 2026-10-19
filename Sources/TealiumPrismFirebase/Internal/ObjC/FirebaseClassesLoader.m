//
//  FirebaseClassesLoader.m
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 21/09/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

#import "FirebaseClassesLoader.h"

#if COCOAPODS
#if defined __has_include && __has_include(<TealiumPrismFirebase-Swift.h>)
#import <TealiumPrismFirebase-Swift.h>
#else
#import <TealiumPrismFirebase/TealiumPrismFirebase-Swift.h>
#endif
#else
#ifdef SWIFT_PACKAGE
@import TealiumPrismFirebase;
#else
#import <TealiumPrismFirebase/TealiumPrismFirebase-Swift.h>
#endif
#endif

@implementation FirebaseClassesLoader

+(void)load {
    [FirebaseAutomaticLoader setup];
}

@end
