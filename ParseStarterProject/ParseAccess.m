//
//  ParseAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//
#import <Parse/Parse.h>
#import "ParseAccess.h"
#import "Image.h"
#import "Like.h"
#import "User.h"
#import "Comment.h"

@implementation ParseAccess

- (instancetype)init{
  self = [super init];
  _images = [[NSMutableArray alloc] init];
  return self;
}

- (void)getImagesWithLimit:(NSUInteger) limit{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query whereKeyExists:@"imageOriginal"];
  if(_offset){
    [query setSkip:_offset];
  }
  [query setLimit:limit];
  _offset += limit;
  [query orderByDescending:@"createdAt"];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    for (PFObject *object in objects) {
      [self getImageObject:object];
    }
  }];
}

//- (void)getImageObject:(NSString*) objectId{
- (void)getImageObject:(PFObject*) objectId{
  
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query includeKey:@"imageOwner"];
  [query getObjectInBackgroundWithId:[objectId objectId] block:^(PFObject * _Nullable object, NSError * _Nullable error) {

    PFFile *image = object[@"imageOriginal"];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
      Image *image = [[Image alloc] init];
      image.imageId = [object objectId];
      image.imageOwner = [object[@"imageOwner"] objectId];
      image.imageOriginal = [UIImage imageWithData:data];
      image.createdDate = [object createdAt];
      [self.images addObject:image];
      
      [self getLikeCountForImage:object];
      [self getLikesForImage:object];
      [self getCommentCountForImage:object];
      [self getCommentsForImage:object];
    }];
  }];
}

- (void)getLikesForImage:(PFObject*)image{
  PFQuery *query = [PFQuery queryWithClassName:@"Like"];
  [query whereKey:@"image" equalTo:image];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    for (Image *imageFromCollection in self.images) {
      if([imageFromCollection.imageId isEqualToString:[image objectId]]){
        if(imageFromCollection.likes == nil){
          imageFromCollection.likes = [[NSMutableArray alloc] init];
        }
        for (PFObject *object in objects) {
          Like *like = [[Like alloc] init];
          like.imageId = [image objectId];
          like.likeDate = [object createdAt];
      
          if (self.users == nil) {
            self.users = [[NSMutableDictionary alloc] init];
          }
          if ([self.users objectForKey:[[object objectForKey:@"user"] objectId]]){
            like.likedByUser = [self.users objectForKey:[[object objectForKey:@"user"] objectId]];
          } else {
            PFUser *user = [object objectForKey:@"user"];
            like.likedByUser = [[User alloc] init];
            like.likedByUser.userId = [user objectId];
            like.likedByUser.username = [user username];
            like.likedByUser.realName = [user objectForKey:@"fullName"];
            //avatar later
          }
          [imageFromCollection.likes addObject:like];
        }
      }
    }
  }];
}

- (void)getCommentsForImage:(PFObject*) image{
  PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
  [query whereKey:@"image" equalTo:image];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    for (Image *imageFromCollection in self.images) {
      if([imageFromCollection.imageId isEqualToString:[image objectId]]){
        if(imageFromCollection.comments == nil){
          imageFromCollection.comments = [[NSMutableArray alloc] init];
        }
        for (PFObject *object in objects) {
          Comment *comment = [[Comment alloc] init];
          comment.imageId = [image objectId];
          comment.createdDate = [object createdAt];
          comment.commentBody = [object valueForKey:@"commentText"];
          
          if (self.users == nil) {
            self.users = [[NSMutableDictionary alloc] init];
          }
          if ([self.users objectForKey:[[object objectForKey:@"user"] objectId]]){
            comment.commentAuthor = [self.users objectForKey:[[object objectForKey:@"user"] objectId]];
          } else {
            PFUser *user = [object objectForKey:@"user"];
            comment.commentAuthor = [[User alloc] init];
            comment.commentAuthor.userId = [user objectId];
            comment.commentAuthor.username = [user username];
            comment.commentAuthor.realName = [user objectForKey:@"fullName"];
            //avatar later
          }
          [imageFromCollection.comments addObject:comment];
        }
      }
    }
  }];
}

- (void)getLikeCountForImage:(PFObject*)image {
  PFQuery *query = [PFQuery queryWithClassName:@"Like"];
  [query whereKey:@"image" equalTo:image];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
    for (Image *imageFromCollection in self.images) {
      if([imageFromCollection.imageId isEqualToString:[image objectId]]){
        imageFromCollection.numberOfLikes = number;
      }
    }
  }];
}

- (void)getCommentCountForImage:(PFObject*)image{
  PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
  [query whereKey:@"image" equalTo:image];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
    for (Image *imageFromCollection in self.images) {
      if([imageFromCollection.imageId isEqualToString:[image objectId]]){
        imageFromCollection.numberOfComments = number;
      }
    }
  }];
}

@end
