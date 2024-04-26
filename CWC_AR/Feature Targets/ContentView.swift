//
//  ContentView.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 24/04/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    //    @StateObject var customARView = CustomARView()
    
    
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                RidikulusView()
            } label: {
                Text("Ridikulus")
            }
            NavigationLink {
                LeviosaView()
            } label: {
                Text("Leviosa")
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
