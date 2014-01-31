//
//  UIDevice+PxUIKit.m
//  PxUIKit
//
//  Created by Jonathan Cichon on 30.01.14.
//  Copyright (c) 2014 pixelflut GmbH. All rights reserved.
//

#import "UIDevice+PxUIKit.h"
#import "UIApplication+PxUIKit.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <PxCore/PxCore.h>

@implementation UIDevice (PxUIKit)

- (NSString *)hardwareIdentifier {
    static NSString *platform = nil;
    if (!platform) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
    }
	return platform;
}

- (NSString *)agentIdentifier {
    static NSString *agentIdentifier = nil;
    if (!agentIdentifier) {
        UIApplication *application = [UIApplication sharedApplication];
        agentIdentifier = [NSString stringWithFormat:@"px|%@|%@|%@|%@|%@", [application applicationName], [application applicationVersion], [self hardwareIdentifier], [self systemVersion], [[NSLocale currentLocale] localeIdentifier]];
    }
    return agentIdentifier;
}

- (NSString *)macAddress {
    static NSString *macAddressString = nil;
    if (!macAddressString) {
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        NSString            *errorFlag = NULL;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
            errorFlag = @"if_nametoindex failure";
        else
        {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
                errorFlag = @"sysctl mgmtInfoBase failure";
            else
            {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL)
                    errorFlag = @"buffer allocation failure";
                else
                {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                        errorFlag = @"sysctl msgBuffer failure";
                }
            }
        }
        
        // Befor going any further...
        if (errorFlag != NULL)
        {
            PxError(@"Error: %@", errorFlag);
            free(msgBuffer);
            return nil;
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        macAddressString = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
                            macAddress[0], macAddress[1], macAddress[2],
                            macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
    }
    
    return macAddressString;
}

@end
