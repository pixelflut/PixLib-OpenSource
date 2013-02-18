/*
 * Copyright (c) 2013 pixelflut GmbH, http://pixelflut.net
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 */

//
//  UIDevice+PixLib.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "UIDevice+PixLib.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "PxCore.h"

@implementation UIDevice (PixLib)

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
        NSDictionary *di = [[NSBundle mainBundle] infoDictionary];
        agentIdentifier = [NSString stringWithFormat:@"px|%@|%@|%@|%@|%@", [di valueForKey:@"CFBundleExecutable"], [di valueForKey:@"CFBundleVersion"], [self hardwareIdentifier], [self systemVersion], [[NSLocale currentLocale] localeIdentifier]];
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
