//
//  ViewController.m
//  ShareDemo
//
//  Created by JK.PENG on 13-8-2.
//  Copyright (c) 2013年 qianwang365. All rights reserved.
//

#import "ViewController.h"
#import "ShareManager.h"
#import "WXApi.h"
#import "WXApiObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isWXAppInstalled{
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装微信客户端" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        [msgbox release];
        return NO;
    }
    return YES;
}

- (IBAction)shareToWX:(id)sender {
    if ([self isWXAppInstalled]) {
        [[ShareManager sharedManager] sendTextContentToWX:@"即使缤纷落尽，繁华消亡，也不要被生活磨平了棱角"
                                                    scene:WXSceneTypeSession
                                          completionBlock:^(ShareManager *manager) {
                                              NSLog(@"======成功：分享文本到朋友=======");
                                              
                                          } failedBlock:^(ShareManager *manager) {
                                              NSLog(@"======失败：分享图片到朋友=======");
                                              
                                          }];
    }
    

}

- (IBAction)shareToWX1:(id)sender {
    
    if ([self isWXAppInstalled]) {
        [[ShareManager sharedManager] sendTextContentToWX:@"即使缤纷落尽，繁华消亡，也不要被生活磨平了棱角"
                                                    scene:WXSceneTypeTimeline
                                          completionBlock:^(ShareManager *manager) {
                                              NSLog(@"======成功：分享文本到朋友圈=======");
                                              
                                              
                                          } failedBlock:^(ShareManager *manager) {
                                              NSLog(@"======失败：分享文本到朋友圈=======");
                                              
                                          }];
    }

    
}

- (IBAction)shareToX2:(id)sender {
    if ([self isWXAppInstalled]) {
        [[ShareManager sharedManager] sendImageContentToWX:[UIImage imageNamed:@"1.jpg"]
                                                     scene:WXSceneTypeSession
                                           completionBlock:^(ShareManager *manager) {
                                               NSLog(@"======成功：分享图片到朋友=======");
                                               
                                               
                                           } failedBlock:^(ShareManager *manager) {
                                               NSLog(@"======失败：分享图片到朋友=======");
                                               
                                           }];
    }
}

- (IBAction)shareToWX3:(id)sender {
    if ([self isWXAppInstalled]) {
        [[ShareManager sharedManager] sendImageContentToWX:[UIImage imageNamed:@"1.jpg"]
                                                     scene:WXSceneTypeTimeline
                                           completionBlock:^(ShareManager *manager) {
                                               NSLog(@"======成功：分享图片到朋友圈=======");
                                               
                                               
                                           } failedBlock:^(ShareManager *manager) {
                                               NSLog(@"======失败：分享图片到朋友圈=======");
                                               
                                           }];
    }

}



- (IBAction)shareToQQ:(id)sender {
    [[ShareManager sharedManager] sendTextContentToQQ:@"即使缤纷落尽，繁华消亡，也不要被生活磨平了棱角"
                                      completionBlock:^(ShareManager *manager) {
                                          NSLog(@"======成功：分享文本到QQ好友=======");

    
                                      } failedBlock:^(ShareManager *manager) {
                                          NSLog(@"======失败：分享文本到QQ好友=======");

                                      }];
}

- (IBAction)shareToQQ1:(id)sender {
    [[ShareManager sharedManager] sendImageContentToQQ:[UIImage imageNamed:@"1.jpg"]
                                                 title:@"清晨"
                                           description:@"早上的浦口"
                                       completionBlock:^(ShareManager *manager) {
                                           NSLog(@"======成功：分享图片到QQ好友=======");

                                       } failedBlock:^(ShareManager *manager) {
                                           NSLog(@"======失败：分享图片到QQ好友=======");

                                       }];
}

@end
