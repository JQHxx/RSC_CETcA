//
// Copyright 2015 Qualcomm Technologies International, Ltd.
//

#import "CSRBridgeRoaming.h"
#import "CSRBluetoothLE.h"
#import "CSRmeshSettings.h"
#import "CSRConstants.h"

//TODO: not sure - may need to remove it
#import <CSRmesh/MeshServiceApi.h>

    /****************************************************************************/
    /*			Private variables and methods									*/
    /****************************************************************************/
// local defines should be declared here
// #define


@interface CSRBridgeRoaming ()  {
}

    // Local Properties should be declared here

@property   (strong, nonatomic) NSMutableSet  *connectedBridges;
@property   (strong, nonatomic) NSMutableSet  *connectingBridges;

@property (nonatomic,assign) BOOL connectting;
@property (nonatomic,assign) NSInteger num;

@end



@implementation CSRBridgeRoaming
@synthesize connectedBridges, connectingBridges;
    /****************************************************************************/
    /*								Interface Methods                           */
    /****************************************************************************/
    // First call will instantiate the one object & initialise it.
    // Subsequent calls will simply return a pointer to the object.

+ (id) sharedInstance {
    static CSRBridgeRoaming *this	= nil;
    
    if (!this)
        this = [[CSRBridgeRoaming alloc] init];
    
    return this;
}


    //============================================================================
    // One time initialisation, called after instantiation of this singleton class
    //

- (id) init {
    self = [super init];
    if (self) {
        [self setupListeners];
        
        connectedBridges = [NSMutableSet set];
        connectingBridges = [NSMutableSet set];
        _connectting = NO;
        _num = 0;
        
        // start background timer thread at 1 second intervals
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(timerThread:)
                                       userInfo:nil
                                        repeats:YES];

    }
    return self;
}

    //============================================================================
    // Timer thread will be triggered once per second
    // Any background functions can be placed here
-(void) timerThread :(id) userInfo {
    static BOOL active=NO;
    if (active==NO) {
        active=YES;
        if (_connectting) {
            _num++;
            if (_num == 5) {
                [connectingBridges removeAllObjects];
                _connectting = NO;
                _num = 0;
            }
        }
        
        NSMutableArray *removals = [NSMutableArray array];
        if ([[CSRmeshSettings sharedInstance] getBleConnectMode] != CSR_BLE_CONNECTIONS_MANUAL) {
            for (CBPeripheral *bridge in connectedBridges) {
                if (bridge.state == CBPeripheralStateDisconnected) {
                    [removals addObject:bridge];
                }
            }
//            for (CBPeripheral *bridge in connectingBridges) {
//                if (bridge.state == CBPeripheralStateDisconnected) {
//                    [removals addObject:bridge];
//                }
//            }
            
            if (removals.count) {
                for (CBPeripheral *bridge in removals) {
                    [connectedBridges removeObject:bridge];
                    [connectingBridges removeObject:bridge];
                }
            }
            
            if (connectedBridges.count < [[CSRmeshSettings sharedInstance] getBleConnectMode])
                [[CSRBluetoothLE sharedInstance] setScanner:YES source:self];
            else
                [[CSRBluetoothLE sharedInstance] setScanner:NO source:self];
        }
        
        self.numberOfConnectedBridges = [connectedBridges count];
    }
    active=NO;
}



    /****************************************************************************/
    /*								Listener Methods                            */
    /****************************************************************************/
    //============================================================================
    // Set up listeners
    //
-(void) setupListeners {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleConnectionModeChanged:)name:CSR_BLE_CONNECTION_MODE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleListenModeChanged:)name:CSR_BLE_LISTEN_MODE object:nil];
}

    // Bridge listen mode has changed so we either need to enable characteristic notifications or disable them
-(void) bleListenModeChanged :(NSNotification *)notification {
    NSNumber *listenMode = notification.userInfo[CSR_BLE_LISTEN_MODE];
    CSRBleListenMode bleListenMode = (CSRBleListenMode)[listenMode integerValue];
    BOOL enableBridgeNotification = YES;
    if (bleListenMode == CSRBleListenMode_ScanListen)
        enableBridgeNotification = NO;
        
    for (CBPeripheral *peripheral in connectedBridges)
        [[MeshServiceApi sharedInstance] connectBridge:peripheral enableBridgeNotification:@(enableBridgeNotification)];
}

    // Bridge listen mode has changed so we either need to enable characteristic notifications or disable them
-(void) bleConnectionModeChanged :(NSNotification *)notification {
    NSNumber *connectionMode = notification.userInfo [CSR_BLE_CONNECTION_MODE];
    NSInteger totalAllowedConnections = [connectionMode integerValue];
    NSInteger totalConnected = connectedBridges.count;
    if (totalConnected > totalAllowedConnections) {
        for (NSInteger i=0; i<(totalConnected-totalAllowedConnections); i++) {
            CBPeripheral *peripheral = [connectedBridges anyObject];
            [[CSRBluetoothLE sharedInstance] disconnectPeripheral:peripheral];
            [connectedBridges removeObject:peripheral];
        }
    }
}



    /****************************************************************************/
    /*								Public Methods                              */
    /****************************************************************************/
    //============================================================================
    // Discovered device
    // This method will be called when a device is discovered
-(NSDictionary *) didDiscoverBridgeDevice:(CBCentralManager *)central peripheral:(CBPeripheral *)peripheral advertisment:(NSDictionary *)advertisment RSSI:(NSNumber *)RSSI {
    
    NSMutableDictionary *returnValue = [NSMutableDictionary dictionary];

    NSInteger totalBridges = [[CSRmeshSettings sharedInstance] getBleConnectMode];
    if (connectedBridges.count<totalBridges && connectingBridges.count<(totalBridges-connectedBridges.count)) {
        
        BOOL found=NO;
        for (CBPeripheral *bridge in connectedBridges) {
            if ([bridge isEqual:peripheral])
                found=YES;
        }
        
        if (!found) {
//            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            [[CSRBluetoothLE sharedInstance] connectPeripheralNoCheck:peripheral];
//            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>SSSSSSSSS");
            _connectting = YES;
            [connectingBridges addObject:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCSRBridgeDiscoveryViewControllerWillRefreshUINotification" object:nil];
        }
    }
    
    return (returnValue);
}

    //============================================================================
    // Disconnected a peripheral
    // Called when a peripheral is diconnected, may or may not be a bridge type of peripheral
-(void) disconnectedPeripheral:(CBPeripheral *) peripheral {
    [connectedBridges removeObject:peripheral];
    [connectingBridges removeObject:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCSRBridgeDiscoveryViewControllerWillRefreshUINotification" object:nil];
}


    //============================================================================
    // connected a peripheral
    // Called when a peripheral is connected, may or may not be a bridge type of peripheral
-(void) connectedPeripheral:(CBPeripheral *) peripheral {
//    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    _connectting = NO;
    [connectedBridges addObject:peripheral];
    [connectingBridges removeObject:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCSRBridgeDiscoveryViewControllerWillRefreshUINotification" object:nil];
}

@end
