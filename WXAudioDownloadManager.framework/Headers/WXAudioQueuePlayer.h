//
//  WXAudioQueuePlayer.h
//  WXAudioDownloadManager
//
//  Created by chunhaixu on 2017/9/12.
//  Copyright © 2017年 chunhaixu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXAudioQueuePlayer;

/// 列表播放模式
typedef NS_ENUM(NSUInteger, WXListPlaybackType) {
    WXListPlaybackTypeSequence, //!< 顺序播放
    WXListPlaybackTypeRandom, //!< 随机播放
    WXListPlaybackTypeLoop, //!< 单曲循环模式
};

/**
 * The audio stream errors.
 */
typedef NS_ENUM(NSInteger, WXAudioPlayerError) {
    /**
     * No error.
     */
    WXAudioPlayerErrorNone = 0,
    /**
     * Error opening the stream.
     */
    WXAudioPlayerErrorOpen = 1,
    /**
     * Error parsing the stream.
     */
    WXAudioPlayerErrorStreamParse = 2,
    /**
     * Network error.
     */
    WXAudioPlayerErrorNetwork = 3,
    /**
     * Unsupported format.
     */
    WXAudioPlayerErrorUnsupportedFormat = 4,
    /**
     * Stream buffered too often.
     */
    WXAudioPlayerErrorStreamBouncing = 5,
    /**
     * Stream playback was terminated by the operating system.
     */
    WXAudioPlayerErrorTerminated = 6
};

@protocol WXAudioQueuePlayerDelegate <NSObject>

@optional
-(void)onAudioPlayerDidStart:(WXAudioQueuePlayer*)player playItem:(NSURL*)item;
-(void)onAudioPlayerDidPlaying:(WXAudioQueuePlayer*)player playItem:(NSURL*)item;
-(void)onAudioPlayerDidStop:(WXAudioQueuePlayer*)player playItem:(NSURL*)item;
-(void)onAudioPlayerDidPause:(WXAudioQueuePlayer*)player playItem:(NSURL*)item;
-(void)onAudioPlayerDidEnd:(WXAudioQueuePlayer*)player playItem:(NSURL*)item;

/// 播放出错回调
-(void)onAudioPlayer:(WXAudioQueuePlayer*)player occurError:(WXAudioPlayerError)err message:(NSString*)msg;

@end


@interface WXAudioQueuePlayer : NSObject

@property (nonatomic, weak) id<WXAudioQueuePlayerDelegate> delegate; //!< 回调代理
@property (nonatomic, assign) WXListPlaybackType playbackType; //!< 播放模式
@property (nonatomic, assign) NSInteger playbackLoopTimes; //!< 单曲播放次数，1-9次否则设置不成功

@property (nonatomic, assign, readonly) NSURL *curURL;
@property (nonatomic, assign, readonly) BOOL isPlaying;

+(instancetype)sharedPlayer;

/// 单个播放当前的音频
-(void)playWithItem:(NSURL *)item;

/// 播放控制
-(void)pause;
-(void)play;
-(void)stop;

/// 切换音量和播放位置
-(BOOL)seekToPosition:(NSInteger)seconds;
-(void)changeVolume:(float)volume;

/// 上一首或下一首
-(void)playNext;
-(void)playPre;

/// 按照播放列表模式进行播放,注意：播放器不维护列表中地址是否重复，需要上层进行判断
-(void)playFromPlaylist:(NSArray<NSURL *> *)playlist itemIndex:(NSUInteger)index;
-(void)playItemAtIndex:(NSInteger)index;
-(void)playItem:(NSURL *)item atPlaylist:(NSArray<NSURL *> *)playlist;

@end
