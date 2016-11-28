//
//  PxSupport.m
//  PixLib-OpenSource
//
//  Created by Jonathan Cichon on 23.11.16.
//  Copyright © 2016 pixelflut GmbH. All rights reserved.
//

#include "PxSupport.h"


CGSize PxScreenSize() {
    static CGSize screen = {0,0};
    if (screen.width == 0 && screen.height == 0) {
        screen = [[UIScreen mainScreen] bounds].size;
    }
    return screen;
}

CGRect PxApplicationFrame() {
    static CGRect appFrame = {{0,0},{0,0}};
    if (CGRectIsEmpty(appFrame)) {
        BOOL opaque = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PxStatusBarOpaque"] boolValue];
        appFrame = [[UIScreen mainScreen] bounds];
        if (opaque) {
            appFrame.size.height -= 20;
            appFrame.origin.y = 20;
        }
    }
    return appFrame;
}
