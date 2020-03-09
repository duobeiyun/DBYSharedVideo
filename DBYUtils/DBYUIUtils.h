//
//  DBYUIUtils.h
//  DBYSDKFullFuncDemo
//
//  Created by Michael on 17/4/10.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DBYUIUtils : NSObject
#pragma mark - color to image
+ (UIImage*)createImageWithColor:(UIColor*)color;

+(UIImage*)bundleImageWithImageName:(NSString*)name;
/**
 *  重新绘制图片
 *
 *  @param color 填充色
 *
 *  @return UIImage
 */
+ (UIImage *)imageChangeColorWithImage:(UIImage *)image color:(UIColor*)color ;
@end
