//
//  WXAudioListCell.h
//  WXPlayerAndDownloadDemo
//
//  Created by chunhai xu on 2017/9/27.
//  Copyright © 2017年 chunhai xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXAudioListCell;
@protocol WXAudioListCellDelegate<NSObject>

@optional
-(void)onDownloadDidClick:(WXAudioListCell*)cell;
-(void)onRemoveDidClick:(WXAudioListCell*)cell;
-(void)onPlayOrNotDidClick:(WXAudioListCell*)cell;
    
    

@end

@interface WXAudioListCell : UITableViewCell

@property(nonatomic, weak) id<WXAudioListCellDelegate> delegate;

@property(nonatomic, strong) IBOutlet UILabel *title;
@property(nonatomic, strong) IBOutlet UILabel *state;

@property(nonatomic, strong) IBOutlet UIButton *downloadBtn;
@property(nonatomic, strong) IBOutlet UIButton *playOrNotBtn;

@end
