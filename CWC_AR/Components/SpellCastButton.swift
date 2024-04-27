//
//  SpellCastButton.swift
//  CWC_AR
//
//  Created by Anggara Satya Wimala Nelwan on 26/04/24.
//

import SwiftUI

struct SpellCastButton: View {
    var micIconWidth:CGFloat
    var micIconHeight:CGFloat
    @State var isRecording:Bool
    @State var color:Color
    
    @Binding var speechText:String
    @Binding var speechAction: SpeechAction
    
    
    public init(micIconWidth: CGFloat = 45, micIconHeight: CGFloat = 55, isRecording: Bool = false, color: Color = .gray, speechText: Binding<String>, speechAction: Binding<SpeechAction>) {
        self.micIconWidth = micIconWidth
        self.micIconHeight = micIconHeight
        self.isRecording = isRecording
        self.color = color
        self._speechText = speechText
        self._speechAction = speechAction
    }
    
    var body: some View {
        ZStack{
            Circle()
                .foregroundColor(.black)
                .frame(width: 90, height: 90)
            Image(systemName: "mic.fill")
                .resizable()
                .frame(width: micIconWidth, height: micIconHeight)
                .foregroundStyle( color )
                .onTapGesture {
                    isRecording.toggle()
                }
        }
        .sheet(isPresented: $isRecording, content: {
            ModalView(isRecording: self.$isRecording, color: self.$color, speechText: self.$speechText, speechAction: self.$speechAction)
                .presentationDetents([.medium, .fraction(0.5)])
                .presentationDragIndicator(.visible)
        })
    }
}

