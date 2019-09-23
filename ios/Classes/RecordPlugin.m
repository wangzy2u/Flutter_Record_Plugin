#import "RecordPlugin.h"
#import <record_plugin/record_plugin-Swift.h>

@implementation RecordPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRecordPlugin registerWithRegistrar:registrar];
}
@end
