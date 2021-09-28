#import "AudioStreamsPlugin.h"
#if __has_include(<audio_streams/audio_streams-Swift.h>)
#import <audio_streams/audio_streams-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "audio_streams-Swift.h"
#endif

@implementation AudioStreamsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioStreamsPlugin registerWithRegistrar:registrar];
}
@end
