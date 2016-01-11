//
//  ParseAccess.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import <Foundation/Foundation.h>

@interface ParseAccess : NSObject

@property (nonatomic) NSUInteger offset;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableDictionary *users;

- (void)getImagesWithLimit:(NSUInteger) limit;
//- (void)getImageObject:(PFObject*) objectId;
//
//- (void)getLikesForImage:(PFObject*)image;
//- (void)getCommentsForImage:(PFObject*) image;
//
////called by getImageObject:
//- (void)getLikeCountForImage:(PFObject*)image;
//- (void)getCommentCountForImage:(PFObject*)image;

@end
