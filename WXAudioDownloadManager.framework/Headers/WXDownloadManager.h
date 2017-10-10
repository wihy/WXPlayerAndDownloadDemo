//
//  WXDownloadManager.h
//  WXAudioDownloadManager
//
//  Created by chunhaixu on 2017/9/12.
//  Copyright © 2017年 chunhaixu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WXDownloadStatus) {
    WXDownloadStatusNotStart = 0, //!< 未开始
    WXDownloadStatusLoading, //!< 正在下载
    WXDownloadStatusFinish, //!< 已完成
    WXDownloadStatusFailed, //!< 失败
};


@protocol WXDownloadManagerDelegate <NSObject>

@optional
-(void)downloadURLDidRemove:(NSString *)url;

-(void)downloadURLDidStart:(NSString *)url;
-(void)downloadURL:(NSString *)url progress:(NSProgress *)progress;
-(void)downloadURL:(NSString *)url finishWithError:(NSError *)err;

-(void)downloadURL:(NSString *)url didChangeStatus:(WXDownloadStatus)status;
@end


@interface WXDownloadManager : NSObject

@property (nonatomic, weak) id<WXDownloadManagerDelegate> delegate;
@property (nonatomic, assign) NSInteger uid; //!< 如果没有用户登录则0
@property (nonatomic, assign) NSUInteger concurrentDownloadTaskCount; //!< 异步下载任务数量，默认3个

+(instancetype)sharedDownloadManager;

/// 重置登录用户的下载数据，需要先调用
/// 用于用户切换之后保存用户数据
-(void)resetDownloadTaskForUser:(NSInteger)uid;

-(BOOL)startAudioDownloadWithURL:(NSString *)url;

-(BOOL)deleteAudioDownloadWithURL:(NSString *)url;

-(BOOL)isAudioDownloadedWithURL:(NSString*)url;

/*!
 @brief 根据提供的url地址从下载记录和目录中查找是否已存在音频文件
 
 @params url 网络地址或本地文件地址
 @return 已存在的下载文件地址或提供的url
 */
-(NSURL *)audioFileURLWithURL:(NSURL *)url;

/// -----------------------------------
/// 在app内部收到进入后台和前台的时候调用相应的方法
/// 处理相关操作任务
/// -----------------------------------
-(void)startBackgroundDownloads;
-(void)endBackgourndDownloads;

@end
