//
//  FTJobCell.m
//  iJenkins
//
//  Created by Ondrej Rafaj on 30/08/2013.
//  Copyright (c) 2013 Fuerte Innovations. All rights reserved.
//

#import "FTJobCell.h"


@interface FTJobCell ()

@end


@implementation FTJobCell


#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    UIEdgeInsets edgeInset = self.separatorInset;
    if (self.hasScore) {
        edgeInset.left = 60;
    } else {
        edgeInset.left = 38;
    }
    self.separatorInset = edgeInset;
}

#pragma mark Creating elements

- (void)createIcons {
    _statusColorView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 14, 14)];
    [_statusColorView.layer setCornerRadius:(_statusColorView.height / 2)];
    [self addSubview:_statusColorView];
    
    _buildScoreView = [[UIImageView alloc] initWithFrame:CGRectMake((_statusColorView.right + 10), 10, 14, 14)];
    [self addSubview:_buildScoreView];
}

- (void)createBuildIdView {
    _buildIdView = [[UILabel alloc] initWithFrame:CGRectMake(10, (54 - 10 - 10), (_buildScoreView.right - 10), 10)];
    [_buildIdView setTextColor:[UIColor grayColor]];
    [_buildIdView setFont:[UIFont systemFontOfSize:10]];
    [_buildIdView setTextAlignment:NSTextAlignmentLeft];
    [_buildIdView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_buildIdView];
}

- (void)createAllElements {
    [super createAllElements];
    
    [self createIcons];
    [self createBuildIdView];
}

#pragma mark Animations

- (void)animate {
    if (_job.animating) {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//            [_statusColorView setAlpha:0];
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//                [_statusColorView setAlpha:1];
//            } completion:^(BOOL finished) {
//                [self animate];
//            }];
//        }];
    }
    else {
        [_statusColorView setAlpha:1];
    }
}

#pragma mark Settings

- (void)reset {
    
}

- (void)resetStatusColor {
    [_statusColorView setBackgroundColor:[_job realColor]];
    [self animate];
}

- (void)resetScoreIcon {
    NSString *iconName;
    if (_job.jobDetail.healthReport.iconUrl == nil && _job.childJobs.count > 0) {
        iconName = @"IJ_health-80plus.png";
    } else {
        iconName = [NSString stringWithFormat:@"IJ_%@", _job.jobDetail.healthReport.iconUrl];
    }
    UIImage *img = [UIImage imageNamed:iconName];
    [_buildScoreView setImage:img];
    if (_job.childJobs.count == 0) {
        [_buildIdView setText:[NSString stringWithFormat:@"#%ld", (long)_job.jobDetail.lastBuild.number]];
    }
}

- (void)setJob:(FTAPIJobDataObject *)job {
    _job = job;
    [self fillData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self resetStatusColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self resetStatusColor];
}

- (void)setDescriptionText:(NSString *)text {
    text = [text stringByReplacingOccurrencesOfString:@"Build stability: " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"Test Result: " withString:@""];
    if (NO) { // Rather not translate this message
        text = FTLangGet(text);
    }
    [self.detailTextLabel setText:text];
}

- (void)fillData {
    [self resetStatusColor];
    if (!_job.jobDetail) {
        [self setDescriptionText:FTLangGet(@"Loading ...")];
        [_buildScoreView setAlpha:0];
        [_buildIdView setText:@"#?"];
    }
    else {
        if (_job.childJobs.count > 0) {
            [self setDescriptionText:[NSString stringWithFormat:@"Folder: %lu Jobs", (unsigned long)_job.childJobs.count]];
        }
        else if (_job.jobDetail.lastBuild.number == 0) {
            [self setDescriptionText:FTLangGet(@"No build has been executed yet")];
        }
        else {
            NSString *description = (_job.jobDetail.healthReport.desc.length > 0) ? _job.jobDetail.healthReport.desc : FTLangGet(FT_NA);
            [self setDescriptionText:description];
        }
        [self resetScoreIcon];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [UIView animateWithDuration:0.15 animations:^{
            [self->_buildScoreView setAlpha:1];
        }];
    }
}

#pragma mark Initialization

- (void)setupView {
    [super setupView];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

#pragma mark Job data object delegate methods

- (void)jobDataObject:(FTAPIJobDataObject *)object didFinishLoadingJobDetail:(FTAPIJobDetailDataObject *)detail {
    [self fillData];
}

- (BOOL)hasScore {
    return YES;
}

@end
