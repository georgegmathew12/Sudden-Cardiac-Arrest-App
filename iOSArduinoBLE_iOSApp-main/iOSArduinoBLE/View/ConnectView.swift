//
//  ConnectView.swift
//  iOSArduinoBLE
//
//  Authors: Andrea Finollo, Leonardo Cavagnis
//

import SwiftUI
import UIKit

struct ConnectView: View {
    
    @ObservedObject var viewModel: ConnectViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var isToggleOn: Bool = false
    @State var isPeripheralReady: Bool = true
    @State var lastTemperature: Int = 0
    @State var lastSteps: Int = 0
    @State var lastDistance: Int = 0
    @State var lastHeartbeat: Int = 0
    @State var heartbeatBoxColor: Color = .green

    var body: some View {
        VStack {
            Text(viewModel.connectedPeripheral.name ?? "Unknown")
                .font(.title)
            ZStack {
                CardView()
                HStack {
                    Text("Led")
                        .padding(.horizontal)
                    Button("On") {
                        viewModel.turnOnLed()
                    }
                    .disabled(!isPeripheralReady)
                    .buttonStyle(.borderedProminent)
                    Button("Off") {
                        viewModel.turnOffLed()
                    }
                    .disabled(!isPeripheralReady)
                    .buttonStyle(.borderedProminent)
                }
            }
            ZStack {
                CardView()
                VStack {
                    Text("\(lastTemperature) °F")
                        .font(.system(size: 24))
                    HStack {
                        Spacer()
                            .frame(alignment: .trailing)
                        Toggle("Notify", isOn: $isToggleOn)
                            .disabled(!isPeripheralReady)
                        Button("Read Temp") {
                            viewModel.readTemperature()
                        }
                        .disabled(!isPeripheralReady)
                        .buttonStyle(.borderedProminent)
                        Spacer()
                            .frame(alignment: .trailing)

                    }
                }
            }
            ZStack {
                CardView()
                VStack {
                    Text("Steps: \(lastSteps)")
                        .font(.system(size: 24))
                    Text("Distance: \(lastDistance) meters")
                        .font(.system(size: 24))
                    HStack {
                        Spacer()
                            .frame(alignment: .trailing)
                        Toggle("Notify", isOn: $isToggleOn)
                            .disabled(!isPeripheralReady)
                        Button("Read Steps") {
                            viewModel.readSteps()
                        }
                        .disabled(!isPeripheralReady)
                        .buttonStyle(.borderedProminent)
                        Button("Read Distance") {
                            viewModel.readDistance()
                        }
                        .disabled(!isPeripheralReady)
                        .buttonStyle(.borderedProminent)
                        Spacer()
                            .frame(alignment: .trailing)
                    }
                }
            }
            ZStack {
                CardView()
                VStack {
                    Text("Heartbeat: \(lastHeartbeat) BPM")
                        .font(.system(size: 24))
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(heartbeatBoxColor)
                        .frame(width: 200, height: 50)
                    HStack {
                        Spacer()
                            .frame(alignment: .trailing)
                        Toggle("Notify", isOn: $isToggleOn)
                            .disabled(!isPeripheralReady)
                        Button("Read Heartbeat") {
                            viewModel.readHeartbeat()
                        }
                        .disabled(!isPeripheralReady)
                        .buttonStyle(.borderedProminent)
                        Spacer()
                            .frame(alignment: .trailing)
                    }
                }
            }
            Spacer()
                .frame(maxHeight:.infinity)
            Button {
                dismiss()
            } label: {
                Text("Disconnect")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .onChange(of: isToggleOn) { newValue in
            if newValue == true {
                print("Toggled")
                viewModel.startNotifyTemperature()
                viewModel.startNotifySteps()
                viewModel.startNotifyDistance()
                viewModel.startNotifyHeartbeat()
            } else {
                viewModel.stopNotifyTemperature()
                viewModel.stopNotifySteps()
                viewModel.stopNotifyDistance()
                viewModel.stopNotifyHeartbeat()
            }
        }
        .onChange(of: lastHeartbeat) {newValue in updateHeartbeatBoxColor(newValue)
        }
        .onReceive(viewModel.$state) { state in
            switch state {
            case .ready:
                isPeripheralReady = true
            case let .temperature(temp):
                lastTemperature = temp
            case let .steps(steps):
                lastSteps = steps
            case let .distance(distance):
                lastDistance = distance
            case let .heartbeat(heartbeat):
                lastHeartbeat = heartbeat
                updateHeartbeatBoxColor(heartbeat)
            default:
                print("Not handled")
            }
        }
    }
    func updateHeartbeatBoxColor(_ heartbeat: Int) {
        if heartbeat >= 160 && heartbeat <= 200 {
            heartbeatBoxColor = .yellow
        } else if heartbeat > 200 {
            heartbeatBoxColor = .red
        } else {
            heartbeatBoxColor = .green
        }
    }
}

struct PeripheralView_Previews: PreviewProvider {
    
    final class FakeUseCase: PeripheralUseCaseProtocol {
        
        var peripheral: Peripheral?
        
        var onWriteLedState: ((Bool) -> Void)?
        var onReadTemperature: ((Int) -> Void)?
        var onReadSteps: ((Int) -> Void)?
        var onReadDistance: ((Int) -> Void)?
        var onReadHeartbeat: ((Int) -> Void)?
        var onPeripheralReady: (() -> Void)?
        var onError: ((Error) -> Void)?
        
        func writeLedState(isOn: Bool) {}
        
        func readTemperature() {onReadTemperature?(0)}
        func readSteps() {onReadSteps?(0)}
        func readDistance() {onReadDistance?(0)}
        func readHeartbeat() {onReadHeartbeat?(0)}
        
        func notifyTemperature(_ isOn: Bool) {}
        func notifySteps(_ isOn: Bool) {}
        func notifyDistance(_ isOn: Bool) {}
        func notifyHeartbeat(_ isOn: Bool) {}
    }
    
    static var viewModel = {
        ConnectViewModel(useCase: FakeUseCase(),
                            connectedPeripheral: .init(name: "iOSArduinoBoard"))
    }()
    
    
    static var previews: some View {
        ConnectView(viewModel: viewModel, isPeripheralReady: true)
    }
}

struct CardView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 16, style: .continuous)
      .shadow(color: Color(white: 0.5, opacity: 0.2), radius: 6)
      .foregroundColor(.init(uiColor: .secondarySystemBackground))
  }
}
