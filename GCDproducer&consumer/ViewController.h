//
//  ViewController.h
//  GCDproducer&consumer
//
//  Created by 刘峰 on 16/7/9.
//  Copyright © 2016年 halovv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSStreamDelegate>
@property (nonatomic, strong) NSMutableArray *mArr;
@property (nonatomic, strong) NSInputStream *inStream;
@property (nonatomic, strong) UIImageView *img;

@end

