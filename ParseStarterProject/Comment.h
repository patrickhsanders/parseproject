//
//  Comment.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Comment : NSObject

@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) User *commentAuthor;
@property (nonatomic, strong) NSString *commentBody;
@property (nonatomic, strong) NSDate *createdDate;

@end
