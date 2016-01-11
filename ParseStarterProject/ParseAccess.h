//
//  ParseAccess.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Image.h"
#import "Like.h"
#import "User.h"
#import "Comment.h"

@interface ParseAccess : NSObject

@property (nonatomic) NSUInteger offset;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableDictionary *users;

- (void)getImagesWithLimit:(NSUInteger) limit;
- (void)getImageObject:(PFObject*) objectId;

- (void)getLikesForImage:(PFObject*)image;
- (void)getCommentsForImage:(PFObject*) image;

- (void)like:(PFObject*)image;
- (void)unlike:(PFObject*)image;

- (void)getLikeCountForImage:(PFObject*)image;
- (void)getCommentCountForImage:(PFObject*)image;

- (void)addComment:(PFObject*)image;

- (void)deleteOwnImage:(PFObject*)image;

- (NSArray *)getLocalImages;

- (void)login:(NSString*)username withPassword:(NSString*)password;
- (void)logout;
- (void)signup:(NSString*)username withPassword:(NSString*)password withAvatar:(UIImage*)avatar withFullName:(NSString*)fullName;

@end
