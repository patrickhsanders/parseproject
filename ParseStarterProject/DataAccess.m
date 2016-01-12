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
//  UIImage *image = [UIImage imageNamed:@"default.png"];
  //[_parse signup:@"django" withPassword:@"django" withAvatar:image withFullName:@"Django"];
  [_parse login:@"django" withPassword:@"django"];
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



#pragma mark Image access and modification methods

- (void)getImages{
  [_parse getImagesWithLimit:10];
}

- (void)addImage:(UIImage*)image{
  [_parse addImageWithImage:image];
  //set uploading spinner
}

- (void)deleteImage:(Image*)image{
  [_parse deleteImageWithId:image.imageId];
  //remove from table view
}

- (void)getActivitiesForImage:(Image*)image{
  //not implemented
}

- (void)updateActivitiesCountForImage:(Image*)image{
  [_parse getActivityCountForImageById:image.imageId];
  //update display or something on notification
}

- (void)likeImage:(Image*)image{
  [_parse likeImageWithId:image.imageId];
  //add one to the display
}

- (void)commentOnImage:(Image*)image withComment:(NSString*)comment{
  [_parse commentImageWithId:image.imageId withComment:comment];
  //add comment to image object
}


#pragma mark Notification handlers for events from Data Source

- (void)loggedInNotification:(NSNotification*)notification{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveImageNotification:) name:@"receiveImageNotification" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNumberOfLikes:) name:@"receiveNumberOfLikes" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNumberOfComments:) name:@"receiveNumberOfComments" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveActivity:) name:@"receiveActivity" object:nil];
  
  [_parse getImagesWithLimit:2];
  
  //[_parse addImageWithImage:[UIImage imageNamed:@"Default.png"]];
  //[_parse likeImageWithId:@"wnO0hoKj80"];
  //[_parse commentImageWithId:@"wnO0hoKj80" withComment:@"monkey butts"];
  //[_parse removeActivityWithId:@"ReuXVI9AXE"];
  [_parse deleteImageWithId:@"dECLGXCkJw"];
  
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
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveActivity:(NSNotification*)notification{
  for (Image *image in _images) {
    if(image.activities == nil){
      image.activities = [[NSMutableArray alloc] init];
    }
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      [image.activities addObject:notification.userInfo[@"activity"]];
    }
  }
//  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveNumberOfLikes:(NSNotification*)notification{
  NSLog(@"likes: %ld", [notification.userInfo[@"likes"] integerValue]);
  for (Image *image in _images) {
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      image.numberOfLikes = [notification.userInfo[@"likes"] integerValue];
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveNumberOfComments:(NSNotification*)notification{
  NSLog(@"comments: %ld", [notification.userInfo[@"comments"] integerValue]);
  for (Image *image in _images) {
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      image.numberOfComments = [notification.userInfo[@"comments"] integerValue];
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

@end
