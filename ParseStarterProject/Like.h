//
//  Like.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Like : NSObject

@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSDate *likeDate;
@property (nonatomic, strong) User *likedByUser;

@end
