//
//  ViewController.swift
//  BLEdemo
//
//  Created by Duncan on 2016/6/30.
//  Copyright © 2016年 Duncan. All rights reserved.
//

import UIKit
import CoreBluetooth


var superCentralManager = CBCentralManager()
var peripheralDic: [String : AnyObject]?
var connectingPeripheral: CBPeripheral?
var knowIdentifierArr: [UUID] = []
var advertisingData: [String : AnyObject]?
var serviceArray = [CBService]()
var characteristicArray = [CBCharacteristic]()
let serviceUUIDString = "E8008802-4143-5453-5162-6C696E6B73EC"
let characteristicUUIDString = "E8009A03-4143-5453-5162-6C696E6B73EC"

//let serviceUUIDString = "627F23DF-4EBD-463E-8BEA-0EFAABCD15C7"
//let characteristicUUIDString = "49AA95C0-C38D-46CB-90A1-50A8F6AA434D"


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var myTimer: Timer?
    var recivedDataArr = [""]
    
    @IBOutlet weak var myLabel: UILabel!

    @IBAction func scanBtnPressed(_ sender: AnyObject) {
        superCentralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "knowPeripheral") != nil{
            knowIdentifierArr = (UserDefaults.standard.object(forKey: "knowPeripheral") as? [UUID])!
        }
        
    }
    //CBCore
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:   print("CoreBluetooth BLE hardware is powered off")
        case .poweredOn:    print("CoreBluetooth BLE hardware is powered on and ready")
        case .resetting:    print("CoreBluetooth BLE hardware is resetting")
        case .unauthorized: print("CoreBluetooth BLE state is unauthorized")
        case .unknown:      print("CoreBluetooth BLE state is unknown")
        case .unsupported:  print("CoreBluetooth BLE hardware is unsupported on this platform")
        }
        
        myTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ViewController.scanForPeripheral), userInfo: nil, repeats: true)
        //superCentralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        if peripheral.name != nil{
 
            showAlertMessage(_message: "Find Devices" + "【" + peripheral.name! + "】")
            print("Find Devices")
            print("\(peripheral)")
            print("\(advertisementData)")
            advertisingData = advertisementData
            
            connectingPeripheral = peripheral
            superCentralManager.connect(peripheral, options: nil)
            print("12345")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        print("【" + peripheral.name! + "】" + "connected")
        
        myTimer?.invalidate()
        superCentralManager.stopScan()
        knowIdentifierArr.append((connectingPeripheral?.identifier)!)
        
        peripheral.discoverServices([CBUUID(string: serviceUUIDString)])
        print(peripheral.services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Found Service!")
        print(connectingPeripheral!.services)
        serviceArray = connectingPeripheral!.services!
        for service in serviceArray{
            peripheral.discoverCharacteristics([CBUUID(string: characteristicUUIDString)], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
        print("Found Characteristics !")
        if service.characteristics != nil{
            characteristicArray = service.characteristics!
            for characteristic in characteristicArray{
                print(characteristic)
                /*/ 發送Hex訊息
                let data: NSData = "09".dataFromHexadecimalString()!
                peripheral.writeValue(data, forCharacteristic: characteristic, type: .WithoutResponse)
                print("Write " + "\(data)")
                */
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                print(characteristic.isNotifying)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: NSError?) {
        if let data = characteristic.value{
            print(data)
            
            guard "\(data)" != "<00>" else {return}
            recivedDataArr.append("\(data)")
            
            guard recivedDataArr != [""] else {return}
            myLabel.text = "\(recivedDataArr)"
            
            scheduleLocal(sender: "\(data)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: NSError?) {
        print("【" + peripheral.name! + "】" + "connecting fail")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("【" + peripheral.name! + "】" + "disconnected")

        myTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ViewController.scanForPeripheral), userInfo: nil, repeats: true)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Modified Services \(invalidatedServices)")
    }
    
    func scanForPeripheral(){
        if knowIdentifierArr != [] {
            let peripheralsArr = superCentralManager.retrievePeripherals(withIdentifiers: knowIdentifierArr)
            print("Retrieving Peripherals...")
            print(peripheralsArr)
            for peripheral in peripheralsArr {
                connectingPeripheral = peripheral
                superCentralManager.connect(connectingPeripheral!, options: nil)
            }
            
        }else{
            let connectedArr = superCentralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: serviceUUIDString)])
            //let connectedArr = superCentralManager.retrieveConnectedPeripheralsWithServices(nil, options: nil)
            
            print("Retrieving Connected Peripherals...")
            print(connectedArr)
            if connectedArr != [] {
                for connected in connectedArr {
                    connectingPeripheral = connected
                    superCentralManager.connect(connectingPeripheral!, options: nil)
                }
            }else{
                superCentralManager.scanForPeripherals(withServices: nil, options: nil)
                print("Scaning For Peripherals...")
            }
        }
    }
    
    //Implement Function
    
    func showAlertMessage(_message: String!) {
        let alertController = UIAlertController(title: "", message: _message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}





extension String {
    
    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a NSData object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// The use of `strtoul` inspired by Martin R at [http://stackoverflow.com/a/26284562/1271826](http://stackoverflow.com/a/26284562/1271826)
    ///
    /// - returns: NSData represented by this hexadecimal string.
    
    func dataFromHexadecimalString() -> NSData? {
        let data = NSMutableData(capacity: characters.count / 2)
        
        let regex = try! RegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.append([num], length: 1)
        }
        
        return data
    }
}


