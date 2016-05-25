//
//  NSString+DVASecure
//  Develapps
//
//  Created by Pablo Romeu on 21/7/15.
//  Copyright (c) 2015 Develapps. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

/**
 A category that enables secure methods for strings
 
 @since 1.0
 */
@interface NSString (DVASecure)

/*
 Generates MD5 strings for plain string
 
 @param a NSString
 @return an MD5 String
 
 @since 1.0
 */

+ (NSString *)dva_generateMD5:(NSString *)string;

/*
 Generates MD5 strings for plain string
 
 @return an MD5 String
 
 @since 1.0
 */
- (NSString *)dva_generateMD5;

@end
