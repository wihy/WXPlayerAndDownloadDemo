//
//  WXAudioListCell.m
//  WXPlayerAndDownloadDemo
//
//  Created by chunhai xu on 2017/9/27.
//  Copyright © 2017年 chunhai xu. All rights reserved.
//

#import "WXAudioListCell.h"

@implementation WXAudioListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)onDownloadClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(onDownloadDidClick:)]) {
        [self.delegate onDownloadDidClick:self];
    }
}

-(IBAction)onPlayClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(onPlayOrNotDidClick:)]) {
        [self.delegate onPlayOrNotDidClick:self];
    }
}

@end
