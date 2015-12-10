//
//  SKRecognizer.h
//  SpeechKit
//
// Copyright 2010, Nuance Communications Inc. All rights reserved.
//
// Nuance Communications, Inc. provides this document without representation 
// or warranty of any kind. The information in this document is subject to 
// change without notice and does not represent a commitment by Nuance 
// Communications, Inc. The software and/or databases described in this 
// document are furnished under a license agreement and may be used or 
// copied only in accordance with the terms of such license agreement.  
// Without limiting the rights under copyright reserved herein, and except 
// as permitted by such license agreement, no part of this document may be 
// reproduced or transmitted in any form or by any means, including, without 
// limitation, electronic, mechanical, photocopying, recording, or otherwise, 
// or transferred to information storage and retrieval systems, without the 
// prior written permission of Nuance Communications, Inc.
// 
// Nuance, the Nuance logo, Nuance Recognizer, and Nuance Vocalizer are 
// trademarks or registered trademarks of Nuance Communications, Inc. or its 
// affiliates in the United States and/or other countries. All other 
// trademarks referenced herein are the property of their respective owners.
//

#import <Foundation/Foundation.h>
#import <SpeechKit/SKRecognition.h>


/*
 Recognition Types 
 These strings are some of the possible values for the type parameter of 
 initWithType:detection:language:delegate:.
*/

/*!
 @abstract Search optimized recognition.
 */
extern NSString * const SKSearchRecognizerType;

/*!
 @abstract Dictation optimized recognition.
 */
extern NSString * const SKDictationRecognizerType;

/*!
 @abstract TV optimized recognition.
 */
extern NSString * const SKTvRecognizerType;

/*!
 @abstract Type for recognizer end-of-speech detection model.
 */
typedef NSUInteger SKEndOfSpeechDetection;

/*!
 @enum End-of-Speech Detection Models
 @abstract These constants define the various end-of-speech detection models
 for the detection parameter of initWithType:detection:language:delegate:.
 @constant SKNoEndOfSpeechDetection Do not detect the end of speech.
 @constant SKShortEndOfSpeechDetection Detect the end of a short phrase with 
 no pauses.  Because this model does not tolerate much silence once speech 
 has started, it detects the end of speech more quickly.
 @constant SKLongEndOfSpeechDetection Detect the end of a longer phrase, 
 sentence or sentences that may have brief pauses.  Because this model 
 tolerates longer (but still brief) intervals of silence in the middle of 
 speech, it is less likely to wrongly detect the end of speech prematurely but 
 also takes longer to detect the end of speech when the speaker is actually
 finished.
 */
enum {
    SKNoEndOfSpeechDetection = 1,
    SKShortEndOfSpeechDetection = 2,
    SKLongEndOfSpeechDetection = 3,
};


@protocol SKRecognizerDelegate;


/*!
 @discussion The SKRecognizer class manages the entire recognition process 
 including audio recording and server communication.  SKRecognizer is designed 
 to carry out a single recognition so after receiving the response the class 
 should be released.  Subsequent recognitions should each be generated by 
 instantiating a new SKRecognizer instance.
 */
@interface SKRecognizer : NSObject

/*!
 @abstract The average power of the most recent audio during recording.
 */
@property(nonatomic,readonly) float audioLevel;

/*!
 @abstract Returns an initialized recognizer and begins the recognition process.
 
 @param type The recognition type.  This allows the server to better anticipate 
 the type of phrases the user is likely to say as well as selecting an 
 appropriate vocabulary of words that the user might say and therefor has an 
 impact on recognition accuracy.  This type is an NSString and should be specified 
 using one of the predefined constants as described in "Recognition Types" unless
 otherwise specified.
 @param detection The end of speech detection model used to automatically 
 determine that speech has stopped.  Choose this value from 
 "End-Of-Speech Detection Models" to reflect the amount of allowable silence 
 within an utterance.  This detector is a second way that recording may be stopped,
 in addition to calling stopRecording on this object in response to a user action.
 @param language This is language spoken by the user and is expressed as an ISO 639 
 language code, followed by an underscore "_", followed by the ISO 3166-1 country 
 code.  For example, an English speaker from the United States would be 
 expressed as "en_US".  A complete list of supported language tags can be found 
 at http://dragonmobile.nuancemobiledeveloper.com/public/index.php?task=faq .
 @param delegate The receiver for recognition responses.  The delegate must 
 implement the SKRecognizerDelegate protocol and will receive a message when the 
 recognition process has completed.
 @result A recognizer object corresponding to the recognition request.
 */
- (id)initWithType:(NSString *)type detection:(SKEndOfSpeechDetection)detection language:(NSString *)language delegate:(id <SKRecognizerDelegate>)delegate;

/*!
 @abstract Stops recording and streaming audio to the speech server.
 
 @discussion This method is used to stop recording audio and continue with the 
 recognition process.  This method must be used when the end of speech detection 
 is disabled and may be used with a end-of-speech detection model in order to 
 allow a user to manually end a recording before the end-of-speech detctor has 
 activated.
 */
- (void)stopRecording;

/*!
 @abstract Cancels the recognition request.
 
 @discussion This method will terminate the recognition request, stopping any 
 ongoing recording and terminating the recognition process.  This will result 
 in the delegate receiving an error message via the 
 recognizer:didFinishWithError:suggestion method unless a recognition result 
 has been or is already being sent to the delegate.
 */
- (void)cancel;

@end


/*!
 @discussion The SKRecognizerDelegate protocol defines the messages sent to a 
 delegate of the SKRecognizer class.  These delegate methods indicate the flow 
 of the recognition process.  The receiver will be notified when the recording 
 has ended and when the recognition process is finished.
 */
@protocol SKRecognizerDelegate <NSObject>

@optional
/*!
 @abstract Sent when the recognizer starts recording audio.
 
 @param recognizer The recognizer sending the message.
 */
- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer;

/*!
 @abstract Sent when the recognizer stops recording audio.
 
 @param recognizer The recognizer sending the message.
 */
- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer;

@required
/*!
 @abstract Sent when the recognition process completes successfully.
 
 @param recognizer The recognizer sending the message.
 @param results The SKRecognition object containing the recognition results.
 
 @discussion This method is only called when the recognition process completes 
 successfully.  The results object contains an array of possible results, with 
 the best result at index 0 or an empty array if no error occurred but no 
 speech was detected.
 */
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results;

/*!
 @abstract Sent when the recognition process completes with an error.
 
 @param recognizer The recognizer sending the message.
 @param error The recognition error.  Possible numeric values for the 
 SKSpeechErrorDomain are listed in SpeechKitError.h and a text description is
 available via the localizedDescription method.
 @param suggestion This is a suggestion to the user about how he or she can 
 improve recognition performance and is based on the audio received.  Examples 
 include moving to a less noisy location if the environment is extremely noisy, or 
 waiting a bit longer to start speaking if the beeginning of the recording seems
 truncated.  Results are often still present and may still be of useful quality.
 
 @discussion This method is called when the recognition process results in an 
 error due to any number of circumstances.  The audio system may fail to 
 initialize, the server connection may be disrupted or a parameter specified
 during initialization, such as language or authentication information was invalid.
 */
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion;

@end