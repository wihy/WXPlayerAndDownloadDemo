//
//  ViewController.m
//  WXPlayerAndDownloadDemo
//
//  Created by chunhai xu on 2017/9/26.
//  Copyright © 2017年 chunhai xu. All rights reserved.
//

#import "ViewController.h"
#import "WXAudioListCell.h"
#import "AFNetworking.h"
#import "WXDownloadManager.h"
#import "WXAudioQueuePlayer.h"

@interface ViewController ()<WXAudioListCellDelegate,WXDownloadManagerDelegate,WXAudioQueuePlayerDelegate>

@property (nonatomic, strong) NSArray *audioList;

@property (nonatomic, strong) NSMutableArray *playList;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.playList = [NSMutableArray array];
    
    ///是要未登录用户目录
    [[WXDownloadManager sharedDownloadManager] resetDownloadTaskForUser:0];
    [WXDownloadManager sharedDownloadManager].delegate = self;
    
    [WXAudioQueuePlayer sharedPlayer].delegate = self;
    
    [self loadAudioList];
}

-(void)loadAudioList{
    
    NSString *audioUrl = @"https://cimili.com/api/v1/favorite/get/track";
    AFHTTPSessionManager *httpSession = [AFHTTPSessionManager manager];
    [httpSession.requestSerializer setValue:@"abc123" forHTTPHeaderField:@"apikey"];
    __weak typeof(self) weakSelf = self;
    [httpSession GET:audioUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *responseObject) {
        
        NSArray *dataList = responseObject[@"data"];
        if ([dataList isKindOfClass:[NSArray class]]) {
            weakSelf.audioList = dataList;
            [weakSelf.tableView reloadData];
        }
        else{
            NSLog(@"**** %@ ",responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"**** %@ ",error);
    }];
    
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
    
    NSInteger index = cell.tag;
    NSDictionary *audioDict = self.audioList[index];
    [[WXDownloadManager sharedDownloadManager] startAudioDownloadWithURL:audioDict[@"audio"]];
    
}
-(void)onPlayOrNotDidClick:(WXAudioListCell*)cell{
    
    NSInteger index = cell.tag;
    NSDictionary *audioDict = self.audioList[index];
    NSString *playUrl = audioDict[@"audio"];
    
    for (int i = 0; i < self.playList.count; i++) {
        NSURL *playURL = self.playList[i];
        if ([playURL.absoluteString isEqualToString:playUrl]) {
            [[WXAudioQueuePlayer sharedPlayer] playFromPlaylist:self.playList itemIndex:i];
            return;
        }
    }
    [self.playList addObject:[NSURL URLWithString:playUrl]];
    
//    [[WXAudioQueuePlayer sharedPlayer] playWithItem:[NSURL URLWithString:audioDict[@"audio"]]];
    [[WXAudioQueuePlayer sharedPlayer] playFromPlaylist:self.playList itemIndex:self.playList.count-1];
    
}


#pragma mark --  WXDownloadManagerDelegate
-(void)downloadURLDidRemove:(NSString *)url{
    NSLog(@"****** %s ,%@",__func__,url);
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
    
}

-(void)onAudioPlayerDidStop:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
     NSLog(@"****** %s ,%@",__func__,item.absoluteString);
}

-(void)onAudioPlayerDidPause:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
    NSLog(@"****** %s ,%@",__func__,item.absoluteString);
}

-(void)onAudioPlayerDidEnd:(WXAudioQueuePlayer*)player playItem:(NSURL*)item{
     NSLog(@"****** %s ,%@",__func__,item.absoluteString);
}

/// 播放出错回调
-(void)onAudioPlayer:(WXAudioQueuePlayer*)player occurError:(WXAudioPlayerError)err message:(NSString*)msg{
    
     NSLog(@"****** %s ,%@",__func__,msg);
}

@end
