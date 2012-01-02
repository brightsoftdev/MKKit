//
//  MKView+Internal.h
//  MKKit
//
//  Created by Matthew King on 12/30/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKView.h"

@interface MKView (Internal)

/** For use by Catagories, notification of a dealloc call. */
- (void)didRelease;

/** Creates the default graphics for instances that support MKGraphicsStructures. */
- (MKGraphicsStructures *)defaultGraphics;

@end
