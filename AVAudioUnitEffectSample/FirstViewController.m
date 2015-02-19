//
//  FirstViewController.m
//  AVAudioUnitEffectSample
//
//  Created by hiraya.shingo on 2015/02/19.
//  Copyright (c) 2015年 hiraya.shingo. All rights reserved.
//

#import "FirstViewController.h"

@import AVFoundation;

@interface FirstViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioUnitDelay *audioUnitDelay;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.engine = [AVAudioEngine new];
    
    // Prepare AVAudioFile
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loop.m4a" ofType:nil];
    self.audioFile = [[AVAudioFile alloc] initForReading:[NSURL fileURLWithPath:path]
                                                   error:nil];
    
    // Prepare AVAudioPlayerNode
    self.audioPlayerNode = [AVAudioPlayerNode new];
    [self.engine attachNode:self.audioPlayerNode];
    
    // Prepare AVAudioUnitDelay
    self.audioUnitDelay = [AVAudioUnitDelay new];
    self.audioUnitDelay.wetDryMix = 50;
    [self.engine attachNode:self.audioUnitDelay];
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:self.audioUnitDelay
                  format:self.audioFile.processingFormat];
    
    [self.engine connect:self.audioUnitDelay
                      to:mixerNode
                  format:self.audioFile.processingFormat];
    
    // Start engine
    NSError *error;
    [self.engine startAndReturnError:&error];
    if (error) {
        NSLog(@"error:%@", error);
    }
}

- (void)play
{
    // Schedule playing audio file
    [self.audioPlayerNode scheduleFile:self.audioFile
                                atTime:nil
                     completionHandler:^() {
                         [self play];
                     }];
    
    // Start playback
    [self.audioPlayerNode play];
}

- (IBAction)didTapPlayButton:(id)sender
{
    if (self.audioPlayerNode.isPlaying) {
        [self.audioPlayerNode stop];
    } else {
        [self play];
    }
}

- (IBAction)didChangeTimeSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.audioUnitDelay.delayTime = slider.value;
}

- (IBAction)didChangeFeedbackSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.audioUnitDelay.feedback = slider.value;
}

- (IBAction)didChangeMixSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.audioUnitDelay.wetDryMix = slider.value;
}

@end
