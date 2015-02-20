//
//  EQViewController.m
//  AVAudioUnitEffectSample
//
//  Created by hiraya.shingo on 2015/02/20.
//  Copyright (c) 2015年 hiraya.shingo. All rights reserved.
//

#import "EQViewController.h"

@import AVFoundation;

@interface EQViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioUnitEQ *audioUnitEQ;

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISlider *highFilterSlider;
@property (weak, nonatomic) IBOutlet UISlider *midFilterSlider;
@property (weak, nonatomic) IBOutlet UISlider *lowFilterSlider;

@property (nonatomic, copy) NSArray *presetNames;

@end

@implementation EQViewController

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
    
    // Prepare AVAudioUnitEQ
    self.audioUnitEQ = [[AVAudioUnitEQ alloc] initWithNumberOfBands:3];
    [self.engine attachNode:self.audioUnitEQ];
    
    // Prepare AVAudioUnitEQFilterParameters
    AVAudioUnitEQFilterParameters *highFilterParameters;
    highFilterParameters = self.audioUnitEQ.bands[0];
    highFilterParameters.filterType = AVAudioUnitEQFilterTypeParametric;
    highFilterParameters.frequency = 8000.0f;
    highFilterParameters.bandwidth = 2.0f;
    highFilterParameters.gain = self.highFilterSlider.value;
    highFilterParameters.bypass = NO;
    
    AVAudioUnitEQFilterParameters *midFilterParameters;
    midFilterParameters = self.audioUnitEQ.bands[1];
    midFilterParameters.filterType = AVAudioUnitEQFilterTypeParametric;
    midFilterParameters.frequency = 1000.0f;
    midFilterParameters.bandwidth = 2.0f;
    midFilterParameters.gain = self.midFilterSlider.value;
    midFilterParameters.bypass = NO;
    
    AVAudioUnitEQFilterParameters *lowFilterParameters;
    lowFilterParameters = self.audioUnitEQ.bands[2];
    lowFilterParameters.filterType = AVAudioUnitEQFilterTypeParametric;
    lowFilterParameters.frequency = 125.0f;
    lowFilterParameters.bandwidth = 2.0f;
    lowFilterParameters.gain = self.lowFilterSlider.value;
    lowFilterParameters.bypass = NO;
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:self.audioUnitEQ
                  format:self.audioFile.processingFormat];
    
    [self.engine connect:self.audioUnitEQ
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

- (IBAction)didChangeHighFilterSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    AVAudioUnitEQFilterParameters *filterParameters = self.audioUnitEQ.bands[0];
    filterParameters.gain = slider.value;
}

- (IBAction)didChangeMidFilterSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    AVAudioUnitEQFilterParameters *filterParameters = self.audioUnitEQ.bands[1];
    filterParameters.gain = slider.value;
}

- (IBAction)didChangeLowFilterSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    AVAudioUnitEQFilterParameters *filterParameters = self.audioUnitEQ.bands[2];
    filterParameters.gain = slider.value;
}

- (IBAction)didChangeEnableSwitchValue:(id)sender
{
    UISwitch *enableSwitch = (UISwitch *)sender;
    self.audioUnitEQ.bypass = !enableSwitch.isOn;
}

@end
