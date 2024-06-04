//
//  PeripheralUseCase.swift
//  iOSArduinoBLE
//
//  Authors: Andrea Finollo, Leonardo Cavagnis
//

import Foundation
import CoreBluetooth

protocol PeripheralUseCaseProtocol {
    
    var peripheral: Peripheral? { get set }
    
    var onWriteLedState: ((Bool) -> Void)? { get set }
    var onReadTemperature: ((Int) -> Void)? { get set }
    var onReadSteps: ((Int) -> Void)? { get set }
    var onReadDistance: ((Int) -> Void)? { get set }
    var onReadHeartbeat: ((Int) -> Void)? { get set }
    var onPeripheralReady: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }


    func writeLedState(isOn: Bool)
    func readTemperature()
    func readSteps()
    func readDistance()
    func readHeartbeat()
    func notifyTemperature(_ isOn: Bool)
    func notifySteps(_ isOn: Bool)
    func notifyDistance(_ isOn: Bool)
    func notifyHeartbeat(_ isOn:Bool)
}

class PeripheralUseCase: NSObject, PeripheralUseCaseProtocol {
    
    var peripheral: Peripheral? {
        didSet {
            self.peripheral?.cbPeripheral?.delegate = self
            discoverServices()
        }
    }
    
    var cbPeripheral: CBPeripheral? {
        peripheral?.cbPeripheral
    }
    
    var onWriteLedState: ((Bool) -> Void)?
    var onReadTemperature: ((Int) -> Void)?
    var onReadSteps: ((Int) -> Void)?
    var onReadDistance: ((Int) -> Void)?
    var onReadHeartbeat: ((Int) -> Void)?
    var onPeripheralReady: (() -> Void)?
    var onError: ((Error) -> Void)?
    
   
    var discoveredServices = [CBUUID : CBService]()
    var discoveredCharacteristics = [CBUUID : CBCharacteristic]()
    
    func discoverServices() {
        cbPeripheral?.discoverServices([UUIDs.ledService, UUIDs.sensorService, UUIDs.stepService, UUIDs.distanceService, UUIDs.heartbeatService])
    }
    
    func writeLedState(isOn: Bool) {
        guard let ledCharacteristic = discoveredCharacteristics[UUIDs.ledStatusCharacteristic] else {
            return
        }
        cbPeripheral?.writeValue(Data(isOn ? [0x01] : [0x00]), for: ledCharacteristic, type: .withResponse)
    }
    
    func readTemperature() {
        guard let tempCharacteristic = discoveredCharacteristics[UUIDs.temperatureCharacteristic] else {
            return
        }
        cbPeripheral?.readValue(for: tempCharacteristic)
    }
    
    func readSteps() {
        guard let stepCharacteristic = discoveredCharacteristics[UUIDs.stepCharacteristic] else {
            return
        }
        cbPeripheral?.readValue(for: stepCharacteristic)
    }
    
    func readDistance() {
        guard let distanceCharacteristic = discoveredCharacteristics[UUIDs.distanceCharacteristic] else {
            return
        }
        cbPeripheral?.readValue(for: distanceCharacteristic)
    }
    
    func readHeartbeat() {
        guard let heartbeatCharacteristic = discoveredCharacteristics[UUIDs.heartbeatCharacteristic] else {
            return
        }
        cbPeripheral?.readValue(for: heartbeatCharacteristic)
    }
    
    func notifyTemperature(_ isOn: Bool) {
        guard let tempCharacteristic = discoveredCharacteristics[UUIDs.temperatureCharacteristic] else {
            return
        }
        cbPeripheral?.setNotifyValue(isOn, for: tempCharacteristic)
    }
    
    func notifySteps(_ isOn: Bool) {
        guard let stepCharacteristic = discoveredCharacteristics[UUIDs.stepCharacteristic] else {
            return
        }
        cbPeripheral?.setNotifyValue(isOn, for: stepCharacteristic)
    }
    
    func notifyDistance(_ isOn: Bool) {
        guard let distanceCharacteristic = discoveredCharacteristics[UUIDs.distanceCharacteristic] else {
            return
        }
        cbPeripheral?.setNotifyValue(isOn, for: distanceCharacteristic)
    }
    
    func notifyHeartbeat(_ isOn: Bool) {
        guard let heartbeatCharacteristic = discoveredCharacteristics[UUIDs.heartbeatCharacteristic] else {
            return
        }
        cbPeripheral?.setNotifyValue(isOn, for: heartbeatCharacteristic)
    }

    
    fileprivate func requiredCharacteristicUUIDs(for service: CBService) -> [CBUUID] {
        switch service.uuid {
        case UUIDs.ledService where discoveredCharacteristics[UUIDs.ledStatusCharacteristic] == nil:
            return [UUIDs.ledStatusCharacteristic]
        case UUIDs.sensorService where discoveredCharacteristics[UUIDs.temperatureCharacteristic] == nil:
            return [UUIDs.temperatureCharacteristic]
        case UUIDs.stepService where discoveredCharacteristics[UUIDs.stepCharacteristic] == nil:
            return [UUIDs.stepCharacteristic]
        case UUIDs.distanceService where discoveredCharacteristics[UUIDs.distanceCharacteristic] == nil:
            return [UUIDs.distanceCharacteristic]
        case UUIDs.heartbeatService where discoveredCharacteristics[UUIDs.heartbeatCharacteristic] == nil:
            return [UUIDs.heartbeatCharacteristic]
        default:
            return []
        }
    }
}

extension PeripheralUseCase: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else {
            return
        }
        for service in services {
            discoveredServices[service.uuid] = service
            let uuids = requiredCharacteristicUUIDs(for: service)
            guard !uuids.isEmpty else {
                return
            }
            peripheral.discoverCharacteristics(uuids, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            discoveredCharacteristics[characteristic.uuid] = characteristic
        }
        
        if discoveredCharacteristics[UUIDs.temperatureCharacteristic] != nil &&
            discoveredCharacteristics[UUIDs.ledStatusCharacteristic] != nil &&
            discoveredCharacteristics[UUIDs.stepCharacteristic] != nil &&
            discoveredCharacteristics[UUIDs.distanceCharacteristic] != nil &&
            discoveredCharacteristics[UUIDs.heartbeatCharacteristic] != nil {
            onPeripheralReady?()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            onError?(error)
            return
        }
        switch characteristic.uuid {
        case UUIDs.ledStatusCharacteristic:
            let value: UInt8 = {
                guard let value = characteristic.value?.first else {
                    return 0
                }
                return value
            }()
            onWriteLedState?(value != 0 ? true : false)
        default:
            fatalError()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case UUIDs.temperatureCharacteristic:
            let value: UInt8 = {
                guard let value = characteristic.value?.first else {
                    return 0
                }
                return value
            }()
            onReadTemperature?(Int(value))
        case UUIDs.stepCharacteristic:
            let value: UInt8 = {
                guard let value = characteristic.value?.first else {
                    return 0
                }
                return value
            }()
            onReadSteps?(Int(value))
        case UUIDs.distanceCharacteristic:
            let value: UInt8 = {
                guard let value = characteristic.value?.first else {
                    return 0
                }
                return value
            }()
            onReadDistance?(Int(value))
        case UUIDs.heartbeatCharacteristic:
            let value: UInt8 = {
                guard let value = characteristic.value?.first else {
                    return 0
                }
                return value
            }()
            onReadHeartbeat?(Int(value))

        default:
            fatalError()
        }
    }
}
