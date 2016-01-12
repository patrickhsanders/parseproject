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
#import "User.h"
#import "Activity.h"

@interface ParseAccess : NSObject

@property (nonatomic) NSUInteger offset;

- (void)getImagesWithLimit:(NSUInteger) limit;
- (void)getImageObject:(PFObject*) objectId;
- (void)getActivityCountForImage:(PFObject*)image withType:(NSString*)type;
- (void)getActivityCountForImageById:(NSString*)imageId;

- (void)addImage:(Image*)image;
  - (void)addImageWithImage:(UIImage*)image;
- (void)deleteImage:(Image*)image;
  - (void)deleteImageWithId:(NSString*)imageId;

- (void)addActivity:(Activity*)activity;
  - (void)likeImageWithId:(NSString*)imageId; //convenience method
  - (void)commentImageWithId:(NSString*)imageId withComment:(NSString*)commentText; //convenience method
- (void)removeActivity:(Activity*)activity;
  - (void)removeActivityWithId:(NSString*)activityId; //convenience method

- (void)login:(NSString*)username withPassword:(NSString*)password;
- (void)logout;
- (void)signup:(NSString*)username withPassword:(NSString*)password withAvatar:(UIImage*)avatar withFullName:(NSString*)fullName;

@end
