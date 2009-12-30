//
//  SFHFKeychainUtils.m
//
//  Created by Buzz Andersen on 10/20/08.
//  Based partly on code by Jonathan Wight, Jon Crosby, and Mike Malone.
//  Copyright 2008 Sci-Fi Hi-Fi. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "SFHFKeychainUtils.h"
#import <Security/Security.h>

static NSString *SFHFKeychainUtilsErrorDomain = @"SFHFKeychainUtilsErrorDomain";

@interface SFHFKeychainUtils (PrivateMethods)
+ (SecKeychainItemRef) getKeychainItemReferenceForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;
@end

@implementation SFHFKeychainUtils

+ (NSString *) getPasswordForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
        if(error != nil)
        {
            *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -2000 userInfo: nil];            
        }
		return nil;
	}
	
	SecKeychainItemRef item = [SFHFKeychainUtils getKeychainItemReferenceForUsername: username andServiceName: serviceName error: error];
	
	if ((error != nil && *error != nil) || !item) {
		return nil;
	}
	
	// from Advanced Mac OS X Programming, ch. 16
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    OSStatus status = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&password);
	
	if (status != noErr) {
        if(error != nil)
        {
            *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];            
        }
		return nil;
    }

	NSString *passwordString = nil;
	
	if (password != NULL) {
		char passwordBuffer[1024];
		
		if (length > 1023) {
			length = 1023;
		}
		strncpy(passwordBuffer, password, length);
		
		passwordBuffer[length] = '\0';
        passwordString = [NSString stringWithCString:passwordBuffer encoding:NSASCIIStringEncoding];
	}
	
	SecKeychainItemFreeContent(&list, password);
    
    CFRelease(item);
    
    return passwordString;
}

+ (BOOL) storeUsername: (NSString *) username andPassword: (NSString *) password forServiceName: (NSString *) serviceName updateExisting: (BOOL) updateExisting error: (NSError **) error {	
	if (!username || !password || !serviceName) {
        if(error != nil)
        {
            *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -2000 userInfo: nil];            
        }
		return NO;
	}
	
	OSStatus status = noErr;
	
	SecKeychainItemRef item = [SFHFKeychainUtils getKeychainItemReferenceForUsername: username andServiceName: serviceName error: error];
	
	if (error != nil && *error != nil && [*error code] != noErr) {
		return NO;
	}
	
    if(error != nil)
    {
        *error = nil;        
    }
	
	if (item) {
		status = SecKeychainItemModifyAttributesAndData(item,
														NULL,
														strlen([password UTF8String]),
														[password UTF8String]);
		
		CFRelease(item);
	}
	else {
		status = SecKeychainAddGenericPassword(NULL,                                     
											   strlen([serviceName UTF8String]), 
											   [serviceName UTF8String],
											   strlen([username UTF8String]),                        
											   [username UTF8String],
											   strlen([password UTF8String]),
											   [password UTF8String],
											   NULL);
	}
	
	if (status != noErr) {
        if(error != nil)
        {
            *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];            
            return NO;
        }
	}
    
    return YES;
}

+ (BOOL) deleteItemForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
        if(error != nil)
        {
            *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: 2000 userInfo: nil];            
        }
		return NO;
	}
    
	if(error != nil)
    {
        *error = nil;        
    }
	
	SecKeychainItemRef item = [SFHFKeychainUtils getKeychainItemReferenceForUsername: username andServiceName: serviceName error: error];
	
	if (error != nil && *error != nil && [*error code] != noErr) {
		return NO;
	}
	
	if (item) {
		OSStatus status = SecKeychainItemDelete(item);
		
		CFRelease(item);

        if (status != noErr) {
            if(error != nil)
            {
                *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];            
                return NO;
            }
        }
	}
	
    return YES;
}

+ (SecKeychainItemRef) getKeychainItemReferenceForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
        if(error != nil)
        {
            *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -2000 userInfo: nil];            
        }
		return nil;
	}
	
    if(error != nil)
    {
        *error = nil;        
    }
		
	SecKeychainItemRef item;
	
	OSStatus status = SecKeychainFindGenericPassword(NULL,
													 strlen([serviceName UTF8String]),
													 [serviceName UTF8String],
													 strlen([username UTF8String]),
													 [username UTF8String],
													 NULL,
													 NULL,
													 &item);
	
	if (status != noErr) {
		if (status != errSecItemNotFound) {
            if(error != nil)
            {
                *error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];                
            }
		}
		
		return nil;		
	}
	
	return item;
}

@end
