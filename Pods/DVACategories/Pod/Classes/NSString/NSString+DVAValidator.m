//
//  NSString+DVAValidator
//  Develapps
//
//  Created by Pablo Romeu on 28/4/15.
//  Copyright (c) 2015 Develapps. All rights reserved.
//

#import "NSString+DVAValidator.h"

static NSString*    const kRegexPhoneNumber =   @"[0-9]{9}";

@implementation NSString (Validators)

-(BOOL)validateRegex:(NSRegularExpression*)regex{
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
                                                        options:NSMatchingAnchored
                                                          range:NSMakeRange(0, self.length)];
    // if there is not a single match // then return an error and NO
    if (numberOfMatches != 1)
    {
        return NO;
    }
    
    return YES;
}

-(BOOL)dva_validatePhoneNumber{
    __block NSError *regError = nil;
    
    static NSRegularExpression *phoneRegularExpression = nil;
    
    static dispatch_once_t phoneOnceToken;
    dispatch_once(&phoneOnceToken, ^{
        phoneRegularExpression = [[NSRegularExpression alloc] initWithPattern:kRegexPhoneNumber options:NSRegularExpressionAnchorsMatchLines error:&regError];
        NSAssert(!regError, @"%s: ERROR CREATING REGULAR EXPRESSION",__PRETTY_FUNCTION__);
    });

    
    return [self validateRegex:phoneRegularExpression];
}

@end
