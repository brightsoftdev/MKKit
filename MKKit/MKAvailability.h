//
//  MKAvailablity.h
//  MKKit
//
//  Created by Matthew King on 9/4/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#define MK_KIT_0_8                          08
#define MK_KIT_0_9                          09
#define MK_KIT_1_0                          10

#define MK_KIT_CURRENT_VERSION              10

#define MK_DEPRECATED_0_9                   __attribute__((deprecated))
#define MK_DEPRECATED_1_0                   __attribute__((deprecated))

#define MK_VISIBLE_ATTRIBUTE                __attribute__((visibility ("default")))

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////// DEBUG/EVENT LOGGING TOGGLE ON OR OFF TO LOG MKKIT EVENTS  ///////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#if DEBUG
    #define MK_EVENT_LOGGING_ON                 1 // 1=ON 0=OFF /////////////////////////////////////
    #define MK_STATUS_LOGGING_ON                1 // 1=ON 0=OFF /////////////////////////////////////
    #define MK_MEMORY_LOGGING_ON                1 // 1=ON 0=OFF /////////////////////////////////////
#else
    #define MK_EVENT_LOGGING_ON                 
    #define MK_STATUS_LOGGING_ON                
    #define MK_MEMORY_LOGGING_ON
#endif

#if MK_LOGGING_ON
    #define MK_LOG(...)                     NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])

    #if MK_EVENT_LOGGING_ON
        #define MK_E_LOG(...)               MK_LOG(__VA_ARGS__)
    #else
        #define MK_E_LOG(...)
    #endif
    
    #if MK_STATUS_LOGGING_ON
        #define MK_S_LOG(...)               MK_LOG(__VA_ARGS__)
    #else
        #define MK_S_LOG(...)
    #endif

    #if MK_MEMORY_LOGGING_ON
        #define MK_M_LOG(...)               MK_LOG(__VA_ARGS__)
    #else
        #define MK_M_LOG(...)
    #endif
#else
    #define MK_LOG(...)
    #define MK_E_LOG(...)
    #define MK_S_LOG(...)
    #define MK_M_LOG(...)
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////
/// ADDTIONAL LIBRARIES AVAILABLE TO MKKIT TOGGLE THE MACROS TO MAKE LIBRARIES AVAILABLE OR NOT.  // 
////////////////////////////////////////////////////////////////////////////////////////////////////

#define MK_FEEDS_ALLOWED                0 // 1=AVAILABLE 0=NONAVAILABLE ////////////////////////////
#define MK_GRAPHS_ALLOWED               0 // 1=AVAILABLE 0=NONAVAILABLE ////////////////////////////