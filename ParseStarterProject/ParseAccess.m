//
//  ParseAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "ParseAccess.h"


@implementation ParseAccess{
}

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

- (void)getImageObject:(PFObject*) objectId{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query includeKey:@"imageOwner"];
  [query getObjectInBackgroundWithId:[objectId objectId] block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    
    PFFile *image = object[@"imageOriginal"];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
      
      
      [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveImageNotification" object:self userInfo:
       @{@"imageId" : [object objectId],
         @"imageOwner" : [object[@"imageOwner"] objectForKey:@"username"],
         @"imageOriginal" : [UIImage imageWithData:data],
         @"createdDate" : [object createdAt]}];
      [self getLikeCountForImage:object];
      [self getCommentCountForImage:object];
      //[self getCommentsForImage:object];
      [self getLikesForImage:objectId];
    }];
  }];
}

- (void)getLikesForImage:(PFObject*)image{
  PFQuery *query = [PFQuery queryWithClassName:@"Like"];
  [query whereKey:@"image" equalTo:image];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    
    for (PFObject *object in objects) {
      Like *like = [[Like alloc] init];
      like.likeId = [object objectId];
      like.imageId = [image objectId];
      like.likeDate = [object createdAt];
      
      [self getUserForLike:object andUser:object[@"user"]];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveLike" object:self userInfo:@{@"imageId" : [image objectId], @"like" : like}];
    }
  }];
}

- (void)getCommentsForImage:(PFObject*) image{
  PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
  [query whereKey:@"image" equalTo:image];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    
    for (PFObject *object in objects) {
      Comment *comment = [[Comment alloc] init];
      comment.commentId = [object objectId];
      comment.imageId = [image objectId];
      comment.createdDate = [object createdAt];
      comment.commentBody = [object valueForKey:@"commentText"];
      
      [self getUserForComment:object andUser:object[@"user"]];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveComment" object:self userInfo:@{@"imageId" : [image objectId], @"comment" : comment}];
    }
  }];
}

- (void)getUserForComment:(PFObject*)object andUser:(PFUser*)parseUser{
  //    if([_users containsObject:object]){
  //
  //    }
  User *user = [[User alloc] init];
  user.userId = [parseUser objectId];
  user.username = [parseUser objectForKey:@"username"];
  user.realName = [parseUser objectForKey:@"fullName"];
  
  PFFile *avatar = parseUser[@"avatar"];
  [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
    if(!error){
      user.avatarImage = [UIImage imageWithData:data];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveUser" object:self userInfo:@{@"userId" : [object objectId],
                                                                                                     @"user" : user,
                                                                                                     @"commentId" : [object objectId]}];
  }];
}

- (void)getUserForLike:(PFObject*)object andUser:(PFUser*)parseUser{
  //    if([_users containsObject:object]){
  //
  //    }
  User *user = [[User alloc] init];
  user.userId = [parseUser objectId];
  user.username = [parseUser objectForKey:@"username"];
  user.realName = [parseUser objectForKey:@"fullName"];
  
  PFFile *avatar = parseUser[@"avatar"];
  [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
    if(!error){
      user.avatarImage = [UIImage imageWithData:data];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveUserForLike" object:self userInfo:@{@"userId" : [object objectId],
                                                                                                            @"user" : user,
                                                                                                            @"likeId" : [object objectId]}];
  }];
}

- (void)getLikeCountForImage:(PFObject*)image {
  PFQuery *query = [PFQuery queryWithClassName:@"Like"];
  [query whereKey:@"image" equalTo:image];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfLikes" object:self userInfo: @{@"imageId" : [image objectId], @"likes" : [NSNumber numberWithInt:number]}];
  }];
}

- (void)getCommentCountForImage:(PFObject*)image{
  PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
  [query whereKey:@"image" equalTo:image];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfComments" object:self userInfo:@{@"imageId" : [image objectId], @"comments" : [NSNumber numberWithInt:number]}];
  }];
}


- (NSArray *)getLocalImages{
  return _images;
}

- (void)login:(NSString*)username withPassword:(NSString*)password{
  PFUser *currentUser = [PFUser currentUser];
  if(currentUser){
    [self logout];
  }
  
  [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
    if(user){
      NSLog(@"Logged in");
      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
    } else {
      NSLog(@"Login fail %@", [error localizedDescription]);
    }
  }];
}

- (void)logout{
  [PFUser logOut]; //synchronous
  [[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
  _images = nil;
}

- (void)signup:(NSString*)username withPassword:(NSString*)password withAvatar:(UIImage*)avatar withFullName:(NSString*)fullName{
  NSData *imageData = UIImagePNGRepresentation(avatar);
  PFFile *avatarImage = [PFFile fileWithName:@"avatar.png" data:imageData];
  [avatarImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    if(succeeded){
      PFUser *user = [PFUser user];
      user.username = username;
      user.password = password;
      user[@"fullName"] = fullName;
      user[@"avatar"] = avatarImage;
      [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
          NSLog(@"Signup success");
        }
      }];
    }
  }];
}

- (void)like:(PFObject*)image{
  PFObject *like = [PFObject objectWithClassName:@"Like"];
  [like setObject:[PFUser currentUser] forKey:@"user"];
  [like setObject:image forKey:@"image"];
  [like saveEventually];
  NSLog(@"LIKED!");
}
- (void)unlike:(PFObject*)image{
  
}

@end