//
//  UUIDs.swift
//  iOSArduinoBLE
//
//  Authors: Andrea Finollo, Leonardo Cavagnis
//

import Foundation
import CoreBluetooth

enum UUIDs {
    static let ledService = CBUUID(string: "e550bcc0-b2a9-41bd-b6fe-b6b3fe107944")
    static let ledStatusCharacteristic = CBUUID(string:  "e550bcc0-b2a9-41bd-b6fe-b6b3fe107944") // Write
    
    static let sensorService = CBUUID(string: "7ac79fc2-f903-44ba-ac69-04285203cd01")
    static let temperatureCharacteristic = CBUUID(string:  "7ac79fc2-f903-44ba-ac69-04285203cd01") // Read | Notify
    
    static let stepService = CBUUID(string: "33a66063-b1f3-48c1-930d-dfacc8f49499")
    static let stepCharacteristic = CBUUID(string:  "33a66063-b1f3-48c1-930d-dfacc8f49499") // Read | Notify
    
    static let distanceService = CBUUID(string: "416318d1-44e2-4705-9dfd-cdbe160651a2")
    static let distanceCharacteristic = CBUUID(string:  "416318d1-44e2-4705-9dfd-cdbe160651a2")
    
    static let heartbeatService = CBUUID(string: "71ec868a-dd68-4866-b31a-c71d77118e69")
    static let heartbeatCharacteristic = CBUUID(string:  "71ec868a-dd68-4866-b31a-c71d77118e69")
}
