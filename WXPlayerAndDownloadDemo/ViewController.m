//
//  ViewController.m
//  WXPlayerAndDownloadDemo
//
//  Created by chunhai xu on 2017/9/26.
//  Copyright © 2017年 chunhai xu. All rights reserved.
//

#import "ViewController.h"
#import "WXAudioListCell.h"
#import <WXAudioDownloadManager/WXDownloadManager.h>
#import <WXAudioDownloadManager/WXAudioQueuePlayer.h>

@interface ViewController ()<WXAudioListCellDelegate,WXDownloadManagerDelegate,WXAudioQueuePlayerDelegate>
{
    
    NSInteger _playbackTimes;
    
    NSInteger _playbackModelIndex;
}
@property (nonatomic, strong) NSArray *playbackModels;
@property (nonatomic, strong) NSArray *playbackTypes;

@property (nonatomic, strong) NSArray *audioList;

@property (nonatomic, strong) NSMutableArray *playList;

    
@property (nonatomic, strong) IBOutlet UIBarButtonItem *preItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pauseOrPlayItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextItem;
    

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.playList = [NSMutableArray array];
    _playbackTimes = 1;
    _playbackModelIndex = 0;
    
    ///三种播放模式
    self.playbackModels = @[@"顺序播放",@"随机播放",@"单曲循环"];
    self.playbackTypes = @[@(WXListPlaybackTypeSequence),@(WXListPlaybackTypeRandom),@(WXListPlaybackTypeLoop)];
    
    ///需要先设置当前的用户id，以保证用户的下载路径唯一
    [[WXDownloadManager sharedDownloadManager] resetDownloadTaskForUser:0];
    
    ///设置播放器和下载器的代理回调
    [WXDownloadManager sharedDownloadManager].delegate = self;
    
    [WXAudioQueuePlayer sharedPlayer].delegate = self;
    
    //
    UIBarButtonItem *playTimesItem =  [[UIBarButtonItem alloc] initWithTitle:@"次数:1" style:UIBarButtonItemStyleDone target:self action:@selector(onPlaytimesDidClick:)];
    self.navigationItem.leftBarButtonItem = playTimesItem;
    
    UIBarButtonItem *playbackModelItem =  [[UIBarButtonItem alloc] initWithTitle:@"顺序播放" style:UIBarButtonItemStyleDone target:self action:@selector(onPlaybackModelDidClick:)];
    self.navigationItem.rightBarButtonItem = playbackModelItem;
    
    ///设置循环播放次数和播放模式
    [WXAudioQueuePlayer sharedPlayer].playbackLoopTimes = _playbackTimes;
    [WXAudioQueuePlayer sharedPlayer].playbackType = [self.playbackTypes[_playbackModelIndex] integerValue];
    
    [self loadAudioList];
}


-(void)onPlaytimesDidClick:(UIBarButtonItem *)barItem{
    
    ///设置播放次数，目前支持1-9
    if (_playbackTimes >= 9) {
        _playbackTimes = 1;
    }
    else{
        _playbackTimes++;
    }
    [WXAudioQueuePlayer sharedPlayer].playbackLoopTimes = _playbackTimes;
    barItem.title = [NSString stringWithFormat:@"次数:%ld",_playbackTimes];
}

-(void)onPlaybackModelDidClick:(UIBarButtonItem *)barItem{
    
    ///设置播放模式，:顺序，随机，循环
    if (_playbackModelIndex >= 2) {
        _playbackModelIndex = 0;
    }
    else{
        _playbackModelIndex++;
    }
    [WXAudioQueuePlayer sharedPlayer].playbackType = [self.playbackTypes[_playbackModelIndex] integerValue];
    barItem.title = [NSString stringWithFormat:@"%@",self.playbackModels[_playbackModelIndex]];
    
}

    
-(IBAction)onPreDidClick:(id)sender{
    
    [[WXAudioQueuePlayer sharedPlayer] playPre];
}

-(IBAction)onNextDidClick:(id)sender{
    
    [[WXAudioQueuePlayer sharedPlayer] playNext];
}
    
-(IBAction)onPlayOrPauseDidClick:(id)sender{
    
    ///使用pause和resume用于从暂停的地方播放
    if([WXAudioQueuePlayer sharedPlayer].isPlaying){
        [[WXAudioQueuePlayer sharedPlayer] pause];
    }
    else{
        [[WXAudioQueuePlayer sharedPlayer] resume];
    }
 
//      //使用stop和play用于从头开始播放
//        if([WXAudioQueuePlayer sharedPlayer].isPlaying){
//            [[WXAudioQueuePlayer sharedPlayer] stop];
//        }
//        else{
//            [[WXAudioQueuePlayer sharedPlayer] play];
//        }

}


-(void)loadAudioList{
    
    NSString *audioUrl = @"https://cimili.com/api/v1/favorite/get/track";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:audioUrl]];
    [request setValue:@"abc123" forHTTPHeaderField:@"apikey"];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        
        if (error) {
             NSLog(@"**** %@ ",error);
        }
        else{
            
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([responseDict isKindOfClass:[NSDictionary class]]) {
                NSArray *dataList = responseDict[@"data"];
                if ([dataList isKindOfClass:[NSArray class]]) {
                    weakSelf.audioList = dataList;
                    
                    for (NSDictionary *audioDict in dataList) {
                        NSString *playUrl = audioDict[@"audio"];
                        [weakSelf.playList addObject:[NSURL URLWithString:playUrl]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf.tableView reloadData];
                    });
                    
                }
                else{
                    NSLog(@"**** %@ ",responseDict);
                }
            }
        }
        
    }];
    [dataTask resume];
    
}


#pragma mark -- UITableViewDataSource/UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.audioList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WXAudioListCell *audioCell = [tableView dequeueReusableCellWithIdentifier:@"audioListIdentifier" forIndexPath:indexPath];
    audioCell.tag = indexPath.row;
    audioCell.delegate = self;
    
    NSDictionary *audioDict = self.audioList[indexPath.row];
    NSString *audioUrl = audioDict[@"audio"];
    audioCell.title.text = audioDict[@"english"];
    audioCell.state.text = [[WXDownloadManager sharedDownloadManager] isAudioDownloadedWithURL:audioUrl]?@"已下载":@"未下载";
    
    
    return audioCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}


#pragma mark ---  WXAudioListCellDelegate
-(void)onDownloadDidClick:(WXAudioListCell*)cell{
    
    ///下载单条声音
    NSInteger index = cell.tag;
    NSDictionary *audioDict = self.audioList[index];
    [[WXDownloadManager sharedDownloadManager] startAudioDownloadWithURL:audioDict[@"audio"]];
    
}
    
-(void)onRemoveDidClick:(WXAudioListCell *)cell{
    
    //删除
    NSInteger index = cell.tag;
    NSDictionary *audioDict = self.audioList[index];
    [[WXDownloadManager sharedDownloadManager] deleteAudioDownloadWithURL:audioDict[@"audio"]];
}
    
-(void)onPlayOrNotDidClick:(WXAudioListCell*)cell{
    
    NSInteger index = cell.tag;
    NSDictionary *audioDict = self.audioList[index];
    NSString *playUrl = audioDict[@"audio"];
    
    for (int i = 0; i < self.playList.count; i++) {
        NSURL *playURL = self.playList[i];
        if ([playURL.absoluteString isEqualToString:playUrl]) {
            [[WXAudioQueuePlayer sharedPlayer] playFromPlaylist:self.playList itemIndex:i];
            break;
        }
    }
    
    
    ///播放单个声音
//    [[WXAudioQueuePlayer sharedPlayer] playWithItem:[NSURL URLWithString:audioDict[@"audio"]]];
    
    ///播放列表并从最后位置播放
//    [[WXAudioQueuePlayer sharedPlayer] playFromPlaylist:self.playList itemIndex:self.playList.count-1];
    
}


#pragma mark --  WXDownloadManagerDelegate
-(void)downloadURLDidRemove:(NSString *)url{
    NSLog(@"****** %s ,%@",__func__,url);
    
    [self.tableView reloadData];
}

-(void)downloadURLDidStart:(NSString *)url{
    NSLog(@"****** %s ,%@",__func__,url);
}
-(void)downloadURL:(NSString *)url progress:(NSProgress *)progress{
    
    NSLog(@"****** %s ,%@, completedUnitCount : %lld",__func__,url,progress.completedUnitCount);
}
-(void)downloadURL:(NSString *)url finishWithError:(NSError *)err{
    
    NSLog(@"****** %s ,%@, err %@",__func__,url,err);
}

-(void)downloadURL:(NSString *)url didChangeStatus:(WXDownloadStatus)status{
    NSLog(@"****** %s ,%@, status %ld",__func__,url,status);
    
    [self.tableView reloadData];
}


#pragma mark -- WXAudioQueuePlayerDelegate
-(void)onAudioPlayerDidStart:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
    
     NSLog(@"****** %s ,%@",__func__,item.absoluteString);
}

-(void)onAudioPlayerDidPlaying:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
     NSLog(@"****** %s ,%@",__func__,item.absoluteString);
    
    self.pauseOrPlayItem.title = @"暂停";
}

-(void)onAudioPlayerDidStop:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
     NSLog(@"****** %s ,%@",__func__,item.absoluteString);
    
    self.pauseOrPlayItem.title = @"播放";
}

-(void)onAudioPlayerDidPause:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
    NSLog(@"****** %s ,%@",__func__,item.absoluteString);
    
    self.pauseOrPlayItem.title = @"播放";
}

-(void)onAudioPlayerDidEnd:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
     NSLog(@"****** %s ,%@",__func__,item.absoluteString);
}

/// 播放出错回调
-(void)onAudioPlayer:(WXAudioQueuePlayer*)player occurError:(WXAudioPlayerError)err message:(NSString*)msg{
    
     NSLog(@"****** %s ,%@",__func__,msg);
}

@end
