//
//  ModalView.swift
//  CWC_AR
//
//  Created by Anggara Satya Wimala Nelwan on 26/04/24.
//

import SwiftUI

struct ModalView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var isRecording:Bool
    @Binding var color:Color
    
    @Binding var speechText:String
    @Binding var speechAction: SpeechAction
    
    var body: some View {
        VStack{
            Spacer()
            Text("\((isRecording == false) ? "":((speechRecognizer.transcript == "") ? "Speak Now": speechRecognizer.transcript))")
                .frame(width: 300, height: 200, alignment: .center)
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
            Spacer()
        }
        .onAppear{
            speechRecognizer.transcribe()
            color = .red
        }
        .onDisappear{
            color = .gray
            speechRecognizer.stopTranscribing()
            speechText = speechRecognizer.transcript
            if speechText == "Reset" {
                speechAction = .remove
            } else if speechText == "Plane"{
                speechAction = .plane
            } else if speechText == "Drummer"{
                speechAction = .drummer
            } else if speechText == "Ridiculous" || speechText == "Ridikulus" {
                speechAction = .ridikulus
            } else if speechText == "Wingardium Leviosa!"{
                speechAction = .leviosa
            }
        }
    }
}

#Preview {
    ModalView(isRecording: .constant(false), color: .constant(.gray), speechText: .constant(""), speechAction: .constant(.none))
}
