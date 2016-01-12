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
  return self;
}

#pragma mark Get methods

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

#pragma mark Fetch image attributes and associated activities

- (void)getImageObject:(PFObject*) objectId{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query includeKey:@"imageOwner"];
  [query getObjectInBackgroundWithId:[objectId objectId] block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    
    PFFile *image = object[@"imageOriginal"];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
      
      PFQuery *userQuery = [PFUser query];
      [userQuery whereKey:@"objectId" equalTo:[object[@"imageOwner"] objectId]];
      [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
        User *imageOwner = [[User alloc] init];
        imageOwner.userId = [user objectId];
        imageOwner.username = [user objectForKey:@"username"];
        imageOwner.realName = [user objectForKey:@"fullName"];
        
        PFFile *avatar = user[@"avatar"];
        [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
          if(!error){
            imageOwner.avatarImage = [UIImage imageWithData:data];
          } else {
            imageOwner.avatarImage = [UIImage imageNamed:@"default-avatar"];
          }
          
          [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveImageNotification" object:self userInfo:
           @{@"imageId" : [object objectId],
             @"imageOwner" : imageOwner,
             @"imageOriginal" : [UIImage imageWithData:data],
             @"createdDate" : [object createdAt]}];
          
          [self getActivityCountForImage:object withType:@"like"];
          [self getActivityCountForImage:object withType:@"comment"];
          [self getActivitiesForImage:object];
          
        }];
      }];
    }];
  }];
}

- (void)getActivitiesForImage:(PFObject*)image{
  PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
  [query whereKey:@"image" equalTo:image];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    if(!error && [objects count] > 0){
      for (PFObject *object in objects) {
        Activity *activity = [[Activity alloc] init];
        activity.activityId = [object objectId];
        activity.imageId = [image objectId];
        activity.activityType = [object valueForKey:@"activityType"];
        if([[object valueForKey:@"activityType"] isEqualToString:@"comment"]){
          activity.commentText = [object valueForKey:@"commentText"];
        }
        
        //[PFQuery getUserObjectWithId:[object[@"activityAuthor"] objectId]];
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:[object[@"activityAuthor"] objectId]];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          
          PFUser *parseUser = object;
          activity.activityAuthor = [[User alloc] init];
          activity.activityAuthor.userId = [parseUser objectId];
          activity.activityAuthor.username = [parseUser objectForKey:@"username"];
          activity.activityAuthor.realName = [parseUser objectForKey:@"fullName"];
          
          PFFile *avatar = parseUser[@"avatar"];
          [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(!error){
              activity.activityAuthor.avatarImage = [UIImage imageWithData:data];
            } else {
              activity.activityAuthor.avatarImage = [UIImage imageNamed:@"default-avatar"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveActivity" object:self userInfo:@{@"imageId" : [image objectId], @"activity" : activity}];
          }];
        }];
      }
    } else {
      if ([objects count] == 0){
        NSLog(@"No activities for image: %@", [image objectId]);
      }
      if (error) {
        NSLog(@"%@", [error localizedDescription]);
      }
    }
  }];
}

- (void)getActivityCountForImage:(PFObject*)image withType:(NSString*)type{
  PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
  [query whereKey:@"image" equalTo:image];
  [query whereKey:@"activityType" equalTo:type];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
    if(!error){
      if ([type isEqualToString:@"comment"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfComments" object:self userInfo:@{@"imageId" : [image objectId], @"comments" : [NSNumber numberWithInt:number]}];
      } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfLikes" object:self userInfo: @{@"imageId" : [image objectId], @"likes" : [NSNumber numberWithInt:number]}];
      }
    } else {
      NSLog(@"%@",[error localizedDescription]);
    }
  }];
}

- (void)getActivityCountForImageById:(NSString*)imageId{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query getObjectInBackgroundWithId:imageId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    if(!error){
      [self getActivityCountForImage:object withType:@"comment"];
      [self getActivityCountForImage:object withType:@"like"];
    }
  }];
}


#pragma mark Image manipulation methods

- (void)addImage:(Image*)image{
  NSData *imageData = UIImagePNGRepresentation(image.imageOriginal);
  PFFile *imageFile = [PFFile fileWithName:@"file.png" data:imageData];
  [imageFile saveInBackground];
  
  PFObject *parseImage = [PFObject objectWithClassName:@"Image"];
  [parseImage setObject:imageFile forKey:@"imageOriginal"];
  [parseImage setObject:[PFUser currentUser] forKey:@"imageOwner"];
  [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    if(succeeded){
      NSLog(@"SUCCEEDED UPLOAD");
    }
  }];
}

- (void)addImageWithImage:(UIImage*)image{
  Image *imageObject = [[Image alloc] init];
  imageObject.imageOriginal = image;
  [self addImage:imageObject];
}

- (void)deleteImage:(Image*)image{
  PFQuery *parseActivity = [PFQuery queryWithClassName:@"Image"];
  [parseActivity getObjectInBackgroundWithId:image.imageId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    if(!error){
      [object deleteInBackground];
      NSLog(@"Image Deleted");
    }
  }];

}

- (void)deleteImageWithId:(NSString *)imageId{
  Image *image = [[Image alloc] init];
  image.imageId = imageId;
  [self deleteImage:image];
}

#pragma mark Activity manipulation methods

- (void)addActivity:(Activity*)activity{
  
  PFQuery *image = [PFQuery queryWithClassName:@"Image"];
  [image getObjectInBackgroundWithId:activity.imageId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    PFObject *parseActivity = [PFObject objectWithClassName:@"Activity"];
    [parseActivity setObject:[PFUser currentUser] forKey:@"activityAuthor"];
    [parseActivity setObject:object forKey:@"image"];
    [parseActivity setObject:activity.activityType forKey:@"activityType"];
    if ([activity.activityType isEqualToString:@"comment"]) {
      [parseActivity setObject:activity.commentText forKey:@"commentText"];
    }
    [parseActivity saveEventually];
    NSLog(@"%@", [activity.activityType isEqualToString:@"comment"] ? @"Commented!" : @"Liked!");
  }];
}

- (void)likeImageWithId:(NSString*)imageId{
  Activity *activity = [[Activity alloc] init];
  activity.activityType = @"like";
  activity.imageId = imageId;
  [self addActivity:activity];
}

- (void)commentImageWithId:(NSString*)imageId withComment:(NSString*)commentText{
  Activity *activity = [[Activity alloc] init];
  activity.activityType = @"comment";
  activity.commentText = commentText;
  activity.imageId = imageId;
  [self addActivity:activity];
}

- (void)removeActivity:(Activity*)activity{
  PFQuery *parseActivity = [PFQuery queryWithClassName:@"Activity"];
  [parseActivity getObjectInBackgroundWithId:activity.activityId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    if(!error){
      [object deleteInBackground];
      NSLog(@"Deleted");
    }
  }];
}

- (void) removeActivityWithId:(NSString*)activityId{
  Activity *activity = [[Activity alloc] init];
  activity.activityId = activityId;
  [self removeActivity:activity];
}

#pragma mark Login/Logout methods

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

@end