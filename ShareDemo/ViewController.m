//
//  ViewController.m
//  ShareDemo
//
//  Created by JK.PENG on 13-8-2.
//  Copyright (c) 2013年 NJUT. All rights reserved.
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


- (IBAction)shareToWX:(id)sender {
    [[ShareManager sharedManager] sendTextContentToWX:@"即使缤纷落尽，繁华消亡，也不要被生活磨平了棱角"
                                                scene:WXSceneTypeSession
                                      completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                          NSLog(@"======成功：分享文本到朋友=======");
                                          
                                      } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                          if (resultCode == ShareContentStateUnInstalled) {
                                              NSLog(@"======您的尚未安装微信客户端=======");

                                          }else{
                                              NSLog(@"======失败：分享图片到朋友=======");
                                          }
                                      }];

}

- (IBAction)shareToWX1:(id)sender {
    [[ShareManager sharedManager] sendTextContentToWX:@"即使缤纷落尽，繁华消亡，也不要被生活磨平了棱角"
                                                scene:WXSceneTypeTimeline
                                      completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                          NSLog(@"======成功：分享文本到朋友圈=======");
                                          
                                          
                                      } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                          if (resultCode == ShareContentStateUnInstalled) {
                                              NSLog(@"======您的尚未安装微信客户端=======");

                                          }else{
                                              NSLog(@"======失败：分享文本到朋友圈=======");
                                          }
                                          
                                          
                                      }];

    
}

- (IBAction)shareToX2:(id)sender {
    [[ShareManager sharedManager] sendImageContentToWX:[UIImage imageNamed:@"1.jpg"]
                                                 scene:WXSceneTypeSession
                                       completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                           NSLog(@"======成功：分享图片到朋友=======");
                                           
                                           
                                       } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                           
                                           if (resultCode == ShareContentStateUnInstalled) {
                                               NSLog(@"======您的尚未安装微信客户端=======");
                                               
                                           }else{
                                               NSLog(@"======失败：分享图片到朋友=======");
                                           }
                                           
                                       }];
}

- (IBAction)shareToWX3:(id)sender {
    [[ShareManager sharedManager] sendImageContentToWX:[UIImage imageNamed:@"1.jpg"]
                                                 scene:WXSceneTypeTimeline
                                       completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                           NSLog(@"======成功：分享图片到朋友圈=======");
                                           
                                           
                                       } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                           if (resultCode == ShareContentStateUnInstalled) {
                                               NSLog(@"======您的尚未安装微信客户端=======");
                                               
                                           }else{
                                               NSLog(@"======失败：分享图片到朋友圈=======");
                                           }
                                           
                                       }];

}



- (IBAction)shareToQQ:(id)sender {
    [[ShareManager sharedManager] sendTextContentToQQ:@"即使缤纷落尽，繁华消亡，也不要被生活磨平了棱角"
                                      completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                          NSLog(@"======成功：分享文本到QQ好友=======");

                                      } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                          if (resultCode == ShareContentStateUnInstalled) {
                                              NSLog(@"======您尚未安装手机QQ客户端=======");

                                          }else{
                                              NSLog(@"======失败：分享文本到QQ好友=======");

                                          }

                                      }];

}

- (IBAction)shareToQQ1:(id)sender {
    [[ShareManager sharedManager] sendImageContentToQQ:[UIImage imageNamed:@"1.jpg"]
                                                 title:@"清晨"
                                           description:@"早上的浦口"
                                       completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                           NSLog(@"======成功：分享图片到QQ好友=======");

                                       } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                           if (resultCode == ShareContentStateUnInstalled) {
                                               NSLog(@"======您尚未安装手机QQ客户端=======");
                                               
                                           }else{
                                               NSLog(@"======失败：分享图片到QQ好友=======");
                                               
                                           }
                                       }];

}

- (IBAction)shareViaEmail:(id)sender {
    
    [[ShareManager sharedManager] shareViaEmailWithTitle:@"标题"
                                                 content:@"这是一封来自钱旺的邮件"
                                                   image:[UIImage imageNamed:@"1.jpg"]
                                         completionBlock:^(ShareManager *manager) {
                                             NSLog(@"Message sent");

                                         } failedBlock:^(ShareManager *manager) {
                                             NSLog(@"Message failed");
                                        }];
}

- (IBAction)shareViaSMS:(id)sender {
    
    //recipients，接收人电话号码，可多人
    [[ShareManager sharedManager] shareViaSMSWithContent:@"加油２０１３"
                                              recipients:nil
                                         completionBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                             NSLog(@"Message sent");

                                         } failedBlock:^(ShareManager *manager, ShareContentState resultCode) {
                                             
                                             if (resultCode == ShareContentStateNotSupport) {
                                                 NSLog(@"======设备不具备短信功能=======");
                                                 
                                             }else{
                                                 NSLog(@"Message failed");
                                                 
                                             }

                                         }];
}

@end
