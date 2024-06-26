//
//  ContentView.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 24/04/24.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ContentView: View {
    //    @StateObject var customARView = CustomARView()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var inputText = ""
    @State private var items = ["plane", "drummer"]
    
    @State private var speechText: String = ""
    @State private var speechAction: SpeechAction = .none
    @State private var isDragable: Bool = false
    @State private var layerColor: Color = .black
    
    func toggleFlashLight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
            } catch {
                print("Toggle torch error")
            }
        }
    }
    
    var body: some View {
        CustomARViewRepresentable()
            .edgesIgnoringSafeArea(.all)
            .overlay {
                ZStack{
                    Rectangle()
                        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        .foregroundColor(layerColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture( isDragable ?
                                  DragGesture()
                            .onChanged { drag in
                                print("Gesture onChanged")
                                print("Translation: \(drag.translation)")
                                print("Location: \(drag.location)")
                                ARManager.shared.actionStream.send(.translateItem(translation: drag.translation))
                            }
                                  : nil
                        )
                        .gesture( isDragable ?
                                  MagnificationGesture()
                            .onChanged { pinch in
                                print("Magnification gesture onChanged")
                                print("Magnitude: \(pinch.magnitude)")
                                ARManager.shared.actionStream.send(
                                    .pinchItem(magnitude: pinch.magnitude))
                            }
                                  : nil
                        )
                    VStack{
                        Spacer()
                        HStack (alignment:.bottom){
                            Spacer()
                            SpellCastButton(speechText: $speechText, speechAction: $speechAction)
                            Spacer()
                        }
                    }
                }
            }
            .onChange(of: speechAction) { oldValue, newValue in
                if newValue == .remove{
                    ARManager.shared.actionStream.send(.removeAllAnchors)
                    speechAction = .none
                    print("Remove all items")
                } else if newValue == .plane{
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    ARManager.shared.actionStream.send(.placeItem(item: "plane"))
                    speechAction = .none
                    print("Plane Added")
                } else if newValue == .drummer{
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    ARManager.shared.actionStream.send(.placeItem(item: "drummer"))
                    speechAction = .none
                    print("Drummer Added")
                } else if newValue == .start{
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    ARManager.shared.actionStream.send(.placeBall)
                    speechAction = .none
                    print("Feather Added")
                } else if newValue == .ridikulus {
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    let items = ["plane", "drummer", "gramophone", "toy_car"]
                    let randomNumber = Int(arc4random_uniform(UInt32(items.count)))
                    let randomItem = items[randomNumber]
                    ARManager.shared.actionStream.send(.placeItem(item: randomItem))
                    speechAction = .none
                    print("Ridukulus spell casted")
                } else if newValue == .leviosa {
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    speechAction = .none
                    isDragable = true
                } else if newValue == .lumos {
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    layerColor = .clear
                    print("Lumos spell casted")
                    speechAction = .none
                } else if newValue == .lumosmaxima {
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    layerColor = .clear
                    toggleFlashLight(on: true)
                    print("Lumos Maxima spell casted")
                    speechAction = .none
                } else if newValue == .nox {
                    ARManager.shared.actionStream.send(.playAudio(status: "success"))
                    toggleFlashLight(on: false)
                    print("Nox spell casted")
                    speechAction = .none
                }
            }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
