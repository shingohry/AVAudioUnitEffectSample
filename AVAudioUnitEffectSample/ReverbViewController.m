//
//  ReverbViewController.m
//  AVAudioUnitEffectSample
//
//  Created by hiraya.shingo on 2015/02/20.
//  Copyright (c) 2015年 hiraya.shingo. All rights reserved.
//

#import "ReverbViewController.h"

@import AVFoundation;

@interface ReverbViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioUnitReverb *audioUnitReverb;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, copy) NSArray *presetNames;

@end

@implementation ReverbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.presetNames = @[
                         @"SmallRoom",
                         @"MediumRoom",
                         @"LargeRoom",
                         @"MediumHall",
                         @"LargeHall",
                         @"Plate",
                         @"MediumChamber",
                         @"LargeChamber",
                         @"Cathedral",
                         @"LargeRoom2",
                         @"MediumHall2",
                         @"MediumHall3",
                         @"LargeHall2",
                         ];
    
    self.engine = [AVAudioEngine new];
    
    // Prepare AVAudioFile
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loop.m4a" ofType:nil];
    self.audioFile = [[AVAudioFile alloc] initForReading:[NSURL fileURLWithPath:path]
                                                   error:nil];
    
    // Prepare AVAudioPlayerNode
    self.audioPlayerNode = [AVAudioPlayerNode new];
    [self.engine attachNode:self.audioPlayerNode];
    
    // Prepare AVAudioUnitDistortion
    self.audioUnitReverb = [AVAudioUnitReverb new];
    [self.audioUnitReverb loadFactoryPreset:AVAudioUnitReverbPresetSmallRoom];
    self.audioUnitReverb.wetDryMix = 50.0f;
    [self.engine attachNode:self.audioUnitReverb];
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:self.audioUnitReverb
                  format:self.audioFile.processingFormat];
    
    [self.engine connect:self.audioUnitReverb
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

- (IBAction)didChangeEnableSwitchValue:(id)sender
{
    UISwitch *enableSwitch = (UISwitch *)sender;
    self.audioUnitReverb.bypass = !enableSwitch.isOn;
}

- (IBAction)didChangeMixSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.audioUnitReverb.wetDryMix = slider.value;
}

#pragma mark -  methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.presetNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.presetNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.audioUnitReverb loadFactoryPreset:row];
}

@end
