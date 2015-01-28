//
//  OTCreateAudioMessageViewController.m
//  entourage
//
//  Created by Hugo Schouman on 26/01/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//


#import <PMAudioRecorderViewController/AudioNoteRecorderViewController.h>
#import "OTCreateAudioMessageViewController.h"

// SoundCloud
#import "SCShareViewController.h"
#import "SCUIErrors.h"

// Audio
#import "AudioNoteRecorderViewController.h"

@interface OTCreateAudioMessageViewController () <AudioNoteRecorderDelegate>

@property (nonatomic, strong) AudioNoteRecorderViewController *audioNoteRecorderController;

@end

@implementation OTCreateAudioMessageViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[AudioNoteRecorderViewController showRecorderWithMasterViewController:self withDelegate:self];
}

/********************************************************************************/
#pragma mark - AudioNoteRecorderDelegate

- (void)audioNoteRecorderDidCancel:(AudioNoteRecorderViewController *)audioNoteRecorder {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)audioNoteRecorderDidTapDone:(AudioNoteRecorderViewController *)audioNoteRecorder withRecordedURL:(NSURL *)recordedURL {
	[self sendToSoundCloudTheSongWithRecordedURL:recordedURL];
}

- (void)sendToSoundCloudTheSongWithRecordedURL:(NSURL *)recordedURL {
	NSURL *trackURL = [NSURL
	                   fileURLWithPath:[
	                       [NSBundle mainBundle] pathForResource:@"tmp" ofType:@"caf"]];

	NSLog(@"recorded URL = %@", [recordedURL path]);
	NSLog(@"track URL = %@", [trackURL path]);

	SCShareViewController *shareViewController;
	SCSharingViewControllerCompletionHandler handler;

	handler = ^(NSDictionary *trackInfo, NSError *error) {
		if (SC_CANCELED(error)) {
			NSLog(@"Canceled!");
		}
		else if (error) {
			NSLog(@"Error: %@", [error localizedDescription]);
		}
		else {
			NSLog(@"Uploaded track: %@", trackInfo);
		}
	};
	shareViewController = [SCShareViewController shareViewControllerWithFileURL:trackURL
	                                                          completionHandler:handler];
	[shareViewController setTitle:@"Recorded Sound"];
	[shareViewController setPrivate:YES];

	[self presentViewController:shareViewController animated:YES completion:nil];
}

@end