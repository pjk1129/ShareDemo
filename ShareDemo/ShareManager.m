//
//  ShareManager.m
//  ShareDemo
//
//  Created by JK.PENG on 13-8-2.
//  Copyright (c) 2013年 NJUT. All rights reserved.
//

#import "ShareManager.h"

static ShareManager   *shareManager;

@interface ShareManager ()

- (void)setCompletionReqBlock:(ShareManagerBlock)aCompletionBlock;
- (void)setFailedReqBlock:(ShareManagerBlock)aFailedBlock;

- (void)handleQQSendResult:(QQApiSendResultCode)sendResult;

@end

@implementation ShareManager
@synthesize tencentOAuth = _tencentOAuth;

- (void)dealloc{
    _completionReqBlock = nil;
    _failureReqBlock = nil;
    [_tencentOAuth release];
    [super dealloc];
}

+ (ShareManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ShareManager alloc] init];
    });
    return shareManager;
}

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)connectWeChatWithAppId:(NSString *)appId
{
    [WXApi registerApp:appId];

}

- (void)connectQQWithQConnectAppKey:(NSString *)qconnectAppKey
{
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:qconnectAppKey andDelegate:self];
}


-(BOOL) handleOpenURL:(NSURL *) url
{
    NSLog(@"handleOpenURL: %@",url.absoluteString);
    NSRange r = [url.absoluteString rangeOfString:kWeiChatAppId];
    if (r.location != NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return [TencentOAuth HandleOpenURL:url];

}


#pragma mark - QQ connect API
- (void) sendImageContentToQQ:(UIImage *)image
                        title:(NSString*)title
                  description:(NSString*)description
              completionBlock:(ShareManagerBlock)aCompletionReqBlock
                  failedBlock:(ShareManagerBlock)aFailedReqBlock
{
    [self setCompletionReqBlock:aCompletionReqBlock];
    [self setFailedReqBlock:aFailedReqBlock];
    
    NSData* data = UIImageJPEGRepresentation(image,0.6);    
    QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:data title:title description:description];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleQQSendResult:sent];
}
- (void) sendTextContentToQQ:(NSString *)text
             completionBlock:(ShareManagerBlock)aCompletionReqBlock
                 failedBlock:(ShareManagerBlock)aFailedReqBlock
{
    [self setCompletionReqBlock:aCompletionReqBlock];
    [self setFailedReqBlock:aFailedReqBlock];
    
    QQApiTextObject* txtObj = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleQQSendResult:sent];
    
}

- (void)handleQQSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - QQ TencentSessionDelegate


#pragma mark - WeiChat API
/*
 * @param image 缩略图
 * @note 大小不能超过32K
 */
- (UIImage *)getWXThumbImage:(UIImage *)image
{
    CGFloat  size  = (image.size.width*image.size.height)/1024;
    CGFloat  scaleSize = (size<32)?1.0:(32/size);
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void) sendImageContentToWX:(UIImage *)image
                        scene:(WXSceneTypeE)sceneSession
              completionBlock:(ShareManagerBlock)aCompletionReqBlock
                  failedBlock:(ShareManagerBlock)aFailedReqBlock;
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[self getWXThumbImage:image]];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(image,0.6);
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    
    //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    if (sceneSession == WXSceneTypeTimeline) {
        req.scene = WXSceneTimeline;
    }
    
    [self setCompletionReqBlock:aCompletionReqBlock];
    [self setFailedReqBlock:aFailedReqBlock];
    
    [WXApi sendReq:req];
}

- (void) sendTextContentToWX:(NSString *)text
                       scene:(WXSceneTypeE)sceneSession
             completionBlock:(ShareManagerBlock)aCompletionReqBlock
                 failedBlock:(ShareManagerBlock)aFailedReqBlock
{
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = YES;
    req.text = text;
    
    //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    if (sceneSession == WXSceneTypeTimeline) {
        req.scene = WXSceneTimeline;
    }
    [self setCompletionReqBlock:aCompletionReqBlock];
    [self setFailedReqBlock:aFailedReqBlock];
    
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate
-(void) onReq:(BaseReq*)req
{

}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        if (resp.errCode == 0) {
            if(_completionReqBlock){
                _completionReqBlock(self);
            }
            _completionReqBlock = nil;
        }else{
            if(_failureReqBlock){
                _failureReqBlock(self);
            }
            
            _failureReqBlock = nil;
        }

    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - Set ReqBlock
- (void)setCompletionReqBlock:(ShareManagerBlock)aCompletionBlock{
    [_completionReqBlock release];
	_completionReqBlock = [aCompletionBlock copy];
    
    
}

- (void)setFailedReqBlock:(ShareManagerBlock)aFailedBlock{
    [_failureReqBlock release];
	_failureReqBlock = [aFailedBlock copy];
    
}

@end
