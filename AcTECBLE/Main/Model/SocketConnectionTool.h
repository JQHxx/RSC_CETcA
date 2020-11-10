//
//  SocketConnectionTool.h
//  AcTECBLE
//
//  Created by AcTEC on 2020/10/23.
//  Copyright © 2020 AcTEC ELECTRONICS Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol SocketConnectionToolDelegate <NSObject>

- (void)saveSonosInfo:(NSNumber *_Nullable)deviceID;
- (void)socketConnectFail:(NSNumber *_Nullable)deviceID;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SocketConnectionTool : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *tcpSocketManager;
@property (nonatomic, assign) NSInteger frameNumber;
@property (nonatomic, assign) NSInteger sourceAddress;
@property (nonatomic, strong) NSMutableData *receiveData;
@property (nonatomic, strong) NSNumber *deviceID;
@property (nonatomic, weak) id<SocketConnectionToolDelegate> delegate;

- (void)connentHost:(NSString *)host prot:(uint16_t)port;
- (NSInteger)getFrameNumber;
- (void)writeData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END