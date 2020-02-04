//
//  BLEManager.swift
//  YipYip
//
//  Created by Marcel Bloemendaal on 24/01/2020.
//  Copyright © 2020 YipYip. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class BLEManager: NSObject {
    
    private var centralManager: CBCentralManager!
    private var connectedPeripherals: Set<CBPeripheral> = Set<CBPeripheral>()
    private var peripheralsBeingConnected: Set<CBPeripheral> = Set<CBPeripheral>()
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        if self.centralManager.state == .poweredOn {
            self.scanForSpeakers()
        }
    }
        
    private func scanForSpeakers() {

        // We tried self.centralManager.retrieveConnectedPeripherals(withServices: ....) to make sure the peripheral we looked for was not already connected,
        // but there never was a result for this. Also: the required peripheral always shows up nicely in the scans.
        
        print("Step 2: Scan for speakers")
        self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            print("Step 1: Central manager state == .poweredOn")
            self.scanForSpeakers()
            
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // For this example we filtered the device purely by name, we obfuscated the device name as we have rather strict NDA with client
        guard let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            name == "<TargetDeviceName>" else {
            return
        }
        
        print("Step 3: Discovered peripheral named: \(name)")

        // Make sure this peripheral is not already connected or being connected
        if !(self.connectedPeripherals.contains(peripheral) || self.peripheralsBeingConnected.contains(peripheral)) {
            print("Step 4: (iOS 13) Connect to target device")
            self.peripheralsBeingConnected.insert(peripheral)
            if #available(iOS 13, *) {
                self.centralManager.connect(peripheral, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
            } else {
                print("Step 4: (pre iOS 13) Connect to target device")
                self.centralManager.connect(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Step 5: Target peripheral connected!")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Peripheral failed to connect!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral disconnected!")
    }
}
