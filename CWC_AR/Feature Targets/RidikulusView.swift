//
//  RidikulusView.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 25/04/24.
//

import SwiftUI

struct RidikulusView: View {
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var inputText = ""
    @State private var items = ["plane", "drummer"]
    
    @State private var colors: [Color] = [
        .green,
        .red,
        .blue
    ]
    
    var body: some View {
        CustomARViewRepresentable()
            .edgesIgnoringSafeArea(.all)
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal){
                    HStack {
                        Button {
                            ARManager.shared.actionStream.send(.removeAllAnchors)
                        } label:{
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(16)
                        }
//                            ForEach(colors, id: \.self) { color in
//                                Button {
//                                    ARManager.shared.actionStream.send(.placeBlock(color: color))
//                                } label: {
//                                    color
//                                        .frame(width: 40, height: 40)
//                                        .padding()
//                                        .background(.regularMaterial)
//                                        .cornerRadius(16)
//                                }
//                            }
//                            ForEach(items, id: \.self) { item in
//                                Button {
//                                    ARManager
//                                        .shared
//                                        .actionStream.send(.placeItem(item: item))
//                                } label: {
//                                    Text(item)
//                                        .padding()
//                                        .background(Color.white)
//                                        .cornerRadius(16)
//                                }
//                            }
                    }
                    .padding()
                }
            }
        TextField("Enter text", text: $inputText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: inputText) { newText in
                let lowercasetext = newText.lowercased()
                
                switch lowercasetext {
                case "start":
                    ARManager.shared.actionStream.send(.placeBlock(color: .blue))
                    break
                case "ridikulus", "ridiculous":
                    let items = ["plane", "drummer"]
                    let randomNumber = Int(arc4random_uniform(UInt32(items.count)))
                    let randomItem = items[randomNumber]
                    ARManager.shared.actionStream.send(.placeItem(item: randomItem))
                default:
                    errorMessage = "Perintah tidak dikenal" // Update error message
                    showError = true // Show error message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showError = false // Hide error message after 2 seconds
                        errorMessage = "" // Clear error message
                    }
                    break
                }
            }
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .foregroundColor(.red)
        }
    }
}
#Preview {
    RidikulusView()
}
