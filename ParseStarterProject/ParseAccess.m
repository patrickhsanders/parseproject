//
//  ParseAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "ParseAccess.h"


@implementation ParseAccess{
  BOOL loggedIn;
}

- (instancetype)init{
  self = [super init];
  _images = [[NSMutableArray alloc] init];
  loggedIn = false;
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
      [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"image"}];
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
          imageFromCollection.numberOfLikes = [objects count];
        }
      }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"likes"}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"numberOfLikes"}];
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
            [self getUserAvatar:user];
          }
          [imageFromCollection.comments addObject:comment];
          imageFromCollection.numberOfComments = [objects count];
        }
      }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"comments"}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"numberOfComments"}];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"numberOfLikes"}];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"numberOfComments"}];
  }];
}

- (void)getUserAvatar:(PFUser*)user{
  PFFile *avatar = user[@"avatar"];
  [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
    if(!error){
      User *userToUpdate = [self.users valueForKey:[user objectId]];
      userToUpdate.avatarImage = [UIImage imageWithData:data];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataParse" object:self userInfo:@{@"update" : @"avatarImageDownloaded"}];
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
      loggedIn = true;
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