//
//  DataAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "DataAccess.h"

@implementation DataAccess

-(instancetype)init {
  self = [super init];
  
  _images = [[NSMutableArray alloc] init];
  
  _parse = [[ParseAccess alloc] init];
  UIImage *image = [UIImage imageNamed:@"default.png"];
  //[_parse signup:@"django" withPassword:@"django" withAvatar:image withFullName:@"Django"];
  [_parse login:@"patrick" withPassword:@"patrick"];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loggedInNotification:)
                                               name:@"LoginSuccess"
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(logoutNotification:)
                                               name:@"LogoutSuccess"
                                             object:nil];
  return self;
}

- (void)loggedInNotification:(NSNotification*)notification{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveImageNotification:) name:@"receiveImageNotification" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNumberOfLikes:) name:@"receiveNumberOfLikes" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNumberOfComments:) name:@"receiveNumberOfComments" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLikes:) name:@"receiveLike" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveComment:) name:@"receiveComment" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUser:) name:@"receiveUser" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUserForLike:) name:@"receiveUserForLike" object:nil];
  
  [_parse getImagesWithLimit:10];
}

- (void)logoutNotification:(NSNotification*)notification{
  _images = nil;
  NSLog(@"Logout");
}

- (void)receiveImageNotification:(NSNotification*)notification{
  Image *image = [[Image alloc] init];
  image.imageId = [notification.userInfo valueForKey:@"imageId"];
  image.imageOwner = [notification.userInfo valueForKey:@"imageOwner"];
  image.imageOriginal = [notification.userInfo valueForKey:@"imageOriginal"];
  image.createdDate = [notification.userInfo valueForKey:@"createdDate"];
  [_images addObject:image];
  NSLog(@"%@",_images);
  
}

- (void)receiveNumberOfLikes:(NSNotification*)notification{
  for (Image *image in _images) {
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      image.numberOfLikes = [notification.userInfo[@"likes"] integerValue];
    }
  }
}

- (void)receiveNumberOfComments:(NSNotification*)notification{
  for (Image *image in _images) {
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      image.numberOfComments = [notification.userInfo[@"comments"] integerValue];
    }
  }
}

- (void)receiveLikes:(NSNotification*)notification{
  for (Image *image in _images) {
    if(image.comments == nil){
      image.likes = [[NSMutableArray alloc] init];
    }
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      [image.likes addObject:notification.userInfo[@"like"]];
    }
  }
}

- (void)receiveComment:(NSNotification*)notification{
  for (Image *image in _images) {
    if(image.comments == nil){
      image.comments = [[NSMutableArray alloc] init];
    }
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      [image.comments addObject:notification.userInfo[@"comment"]];
    }
  }
}

- (void)receiveUser:(NSNotification*)notification{
  //get user from the notification
  User *user = notification.userInfo[@"user"];
  
  //check if user is in the dictionary, if not add it
  if(_users == nil){
    _users = [[NSMutableDictionary alloc] init];
  }
  if(![_users valueForKey:notification.userInfo[@"userId"]]){
    [_users setValue:user forKey:notification.userInfo[@"userId"]];
  }
  
  for (Image *image in _images) {
    for (Comment *comment in image.comments) {
      if([comment.commentId isEqualToString:notification.userInfo[@"commentId"]]){
        comment.commentAuthor = user;
      }
    }
  }
}

- (void)receiveUserForLike:(NSNotification*)notification{
  User *user = notification.userInfo[@"user"];
  
  if(_users == nil){
    _users = [[NSMutableDictionary alloc] init];
  }
  if(![_users valueForKey:notification.userInfo[@"userId"]]){
    [_users setValue:user forKey:notification.userInfo[@"userId"]];
  }
  
  for (Image *image in _images) {
    for (Like *like in image.likes) {
      if([like.likeId isEqualToString:notification.userInfo[@"likeId"]]){
        like.likedByUser = user;
      }
    }
  }
}

@end
