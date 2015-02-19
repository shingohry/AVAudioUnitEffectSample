//
//  SecondViewController.m
//  AVAudioUnitEffectSample
//
//  Created by hiraya.shingo on 2015/02/19.
//  Copyright (c) 2015年 hiraya.shingo. All rights reserved.
//

#import "SecondViewController.h"

@import AVFoundation;

@interface SecondViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioUnitDistortion *audioUnitDistortion;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, copy) NSArray *presetNames;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.presetNames = @[
                         @"DrumsBitBrush",
                         @"DrumsBufferBeats",
                         @"DrumsLoFi",
                         @"MultiBrokenSpeaker",
                         @"MultiCellphoneConcert",
                         @"MultiDecimated1",
                         @"MultiDecimated2",
                         @"MultiDecimated3",
                         @"MultiDecimated4",
                         @"MultiDistortedFunk",
                         @"MultiDistortedCubed",
                         @"MultiDistortedSquared",
                         @"MultiEcho1",
                         @"MultiEcho2",
                         @"MultiEchoTight1",
                         @"MultiEchoTight2",
                         @"MultiEverythingIsBroken",
                         @"SpeechAlienChatter",
                         @"SpeechCosmicInterference",
                         @"SpeechGoldenPi",
                         @"SpeechRadioTower",
                         @"SpeechWaves",
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
    self.audioUnitDistortion = [AVAudioUnitDistortion new];
    [self.audioUnitDistortion loadFactoryPreset:AVAudioUnitDistortionPresetDrumsBitBrush];
    self.audioUnitDistortion.wetDryMix = 50.0f;
    [self.engine attachNode:self.audioUnitDistortion];
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:self.audioUnitDistortion
                  format:self.audioFile.processingFormat];
    
    [self.engine connect:self.audioUnitDistortion
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

- (IBAction)didChangeMixSliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    self.audioUnitDistortion.wetDryMix = slider.value;
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
    [self.audioUnitDistortion loadFactoryPreset:row];
}

@end