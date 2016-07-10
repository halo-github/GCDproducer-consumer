//
//  ViewController.m
//  GCDproducer&consumer
//
//  Created by 刘峰 on 16/7/9.
//  Copyright © 2016年 halovv. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    dispatch_semaphore_t sem;
    NSInteger a;
    uint8_t *buffer;
    NSInteger buffSize;
    NSInteger fileSize;
    NSInteger readBts;
    NSMutableData *buffData;
    BOOL isReady;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isReady = NO;
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
//    _img.image = [UIImage imageNamed:@"1.jpg"];
    [self.view addSubview:_img];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    self.inStream = [[NSInputStream alloc] initWithFileAtPath:path];
    //以流的形式读取文件，减少消耗
    [self.inStream open];
    
    NSDictionary  *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    fileSize = [[attr objectForKey:NSFileSize] integerValue];//文件大小
    buffer = malloc(1024);
    buffSize = 0;
    buffData = [[NSMutableData alloc] init];
//    a = 0;
    sem = dispatch_semaphore_create(0);//初始化信号
    [self consumer];
    [self producer];
}
-(void)producer
{
//    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        while (_inStream.hasBytesAvailable) {
            if (!isReady ) {
//             dispatch_semaphore_wait得到通知时返回0
                if (!dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC))) {
                    //                    a++;
                    //                    NSLog(@"producer:a = %ld",(long)a);
                    readBts = [_inStream read:buffer + buffSize maxLength:8];
                    buffSize += readBts;
                    if ( buffSize > 1016) {//根据buff的大小（1024）确定是否可以组装
                        isReady = YES;
                    }
                }
            }
        }
        isReady = YES;//无byte可读，while循环退出，最后一个buff就绪
    });
}

-(void)consumer
{
//    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        while (1) {
//            dispatch_semaphore_signal等待线程未唤醒返回0
            if (!dispatch_semaphore_signal(sem)) {
                if (isReady) {
                    [buffData appendData:[NSData dataWithBytes:buffer length:buffSize]];
                    buffSize = 0;//初始化大小，下次写入重新回到buff头，
                    NSLog(@"%ld---%ld",buffData.length,fileSize);
                    isReady = NO;//初始化，表示buff未就绪
                    if (buffData.length == fileSize) {//整个读取完成
                        [_inStream close];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _img.image = [UIImage imageWithData:buffData];
                        });
                        break;//中断while循环
                    }
                    //                    a --;
                    //                    NSLog(@"consumer : a = %ld",(long)a);
                }
            }
        }
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
