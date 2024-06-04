//
//  ConnectViewModel.swift
//  iOSArduinoBLE
//
//  Authors: Andrea Finollo, Leonardo Cavagnis
//

import Foundation

final class ConnectViewModel: ObservableObject {
    @Published var state = State.idle
    
    var useCase: PeripheralUseCaseProtocol
    let connectedPeripheral: Peripheral
    
    init(useCase: PeripheralUseCaseProtocol,
         connectedPeripheral: Peripheral) {
        self.useCase = useCase
        self.useCase.peripheral = connectedPeripheral
        self.connectedPeripheral = connectedPeripheral
        self.setCallbacks()
    }
    
    private func setCallbacks() {
        useCase.onPeripheralReady = { [weak self] in
            self?.state = .ready
        }
        
        useCase.onReadTemperature = { [weak self] value in
            self?.state = .temperature(value)
        }
        
        useCase.onReadSteps = { [weak self] value in
            self?.state = .steps(value)
        }
        
        useCase.onReadDistance = { [weak self] value in
            self?.state = .distance(value)
        }
        
        useCase.onReadHeartbeat = { [weak self] value in
            self?.state = .heartbeat(value)
        }
        
        useCase.onWriteLedState = { [weak self] value in
            self?.state = .ledState(value)
        }
        
        useCase.onError = { error in
            print("Error \(error)")
        }
    }
    
    func turnOnLed() {
        useCase.writeLedState(isOn: true)
    }
    
    func turnOffLed() {
        useCase.writeLedState(isOn: false)
    }
    
    func startNotifyTemperature() {
        useCase.notifyTemperature(true)
    }
    
    func stopNotifyTemperature() {
        useCase.notifyTemperature(false)
    }
    
    func readTemperature() {
        useCase.readTemperature()
    }
    
    func startNotifySteps() {
        useCase.notifySteps(true)
    }
    
    func stopNotifySteps() {
        useCase.notifySteps(false)
    }
    
    func readSteps() {
        useCase.readSteps()
    }
    
    func startNotifyDistance() {
        useCase.notifyDistance(true)
    }
    
    func stopNotifyDistance() {
        useCase.notifyDistance(false)
    }
    
    func readDistance() {
        useCase.readDistance()
    }

    func startNotifyHeartbeat() {
        useCase.notifyHeartbeat(true)
    }
    
    func stopNotifyHeartbeat() {
        useCase.notifyHeartbeat(false)
    }
    
    func readHeartbeat() {
        useCase.readHeartbeat()
    }
}

extension ConnectViewModel {
    enum State {
        case idle
        case ready
        case temperature(Int)
        case ledState(Bool)
        case steps(Int)
        case distance(Int)
        case heartbeat(Int)
    }
}
