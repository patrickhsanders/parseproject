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
  
  _parse = [[ParseAccess alloc] init];
  [_parse addObserver:self forKeyPath:@"images" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
  [_parse getImagesWithLimit:1];
  
  
  
  return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  
  NSLog(@"change in KVO");
}

@end
