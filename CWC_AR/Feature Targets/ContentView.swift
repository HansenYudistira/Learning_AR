//
//  ContentView.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 24/04/24.
//

import SwiftUI
import RealityKit
import ARKit

enum SpeechAction{
    case none, remove, plane, drummer, ridikulus
    
    //    var action: String{
    //        switch self{
    //        case .remove
    //        }
    //    }
}

struct ContentView: View {
    //    @StateObject var customARView = CustomARView()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var inputText = ""
    @State private var items = ["plane", "drummer"]
    
    @State private var speechText: String = ""
    @State private var speechAction: SpeechAction = .none
    
    var body: some View {
        CustomARViewRepresentable()
            .edgesIgnoringSafeArea(.all)
            .overlay {
                ZStack{
                    Rectangle()
                        .opacity(0)
                        .frame(width: .infinity, height: .infinity)
                        .gesture(
                            DragGesture()
                                .onChanged{ drag in
//                                    position = drag.location
                                    print(drag.translation)
                                    print(drag.location)
                                }
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
                    ARManager.shared.actionStream.send(.placeItem(item: "plane"))
                    speechAction = .none
                    print("Plane Added")
                } else if newValue == .drummer{
                    ARManager.shared.actionStream.send(.placeItem(item: "drummer"))
                    speechAction = .none
                    print("Drummer Added")
                } else if newValue == .ridikulus{
                    let items = ["plane", "drummer"]
                    let randomNumber = Int(arc4random_uniform(UInt32(items.count)))
                    let randomItem = items[randomNumber]
                    ARManager.shared.actionStream.send(.placeItem(item: randomItem))
                    speechAction = .none
                    print("Ridukulus spell casted")
                }
            }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
