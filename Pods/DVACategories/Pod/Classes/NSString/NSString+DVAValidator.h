//
//  NSString+DVAValidator
//  Develapps
//
//  Created by Pablo Romeu on 28/4/15.
//  Copyright (c) 2015 Develapps. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 A category that enables validators for a string
 
 @since 1.0
 */
@interface NSString (DVAValidator)

/**
 Validates a phone number that matches exactly [0-9]{9} 
 
 Example:   
    
 -  @"961999444"                    Matches
 -  @" 961999444",@" 961999444 "    Do not match
 -  @"961999444 961999444"          Do not match
 -  @"a 961999444 a"                Does not match
 
 @return whether it is valid phone number or not
 
 @since 1.0
 */
-(BOOL)dva_validatePhoneNumber;

@end
