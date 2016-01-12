//
//  DataAccess.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import <Foundation/Foundation.h>
#import "ParseAccess.h"
#import "Image.h"

@interface DataAccess : NSObject

@property (nonatomic, strong) ParseAccess *parse;
@property (nonatomic, strong) NSMutableArray *images;

- (void)getImages;

- (void)addImage:(UIImage*)image;
- (void)deleteImage:(Image*)image;
- (void)getActivitiesForImage:(Image*)image;
- (void)updateActivitiesCountForImage:(Image*)image;

- (void)likeImage:(Image*)image;
- (void)commentOnImage:(Image*)image withComment:(NSString*)comment;


@end
