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
            speechText = speechRecognizer.transcript.lowercased()
            if speechText == "reset" {
                speechAction = .remove
            } else if speechText == "start" {
                speechAction = .start
            } else if speechText.hasSuffix("drummer") {
                speechAction = .drummer
            } else if speechText.hasSuffix("plane") {
                speechAction = .plane
            } else if speechText == "ridiculous" || speechText == "ridikulus" {
                speechAction = .ridikulus
            } else if speechText == "wingardium leviosa!" {
                speechAction = .leviosa
            } else if speechText == "lumos" {
                speechAction = .lumos
            } else if speechText == "lumos maxima" {
                speechAction = .lumosmaxima
            } else if speechText == "nox" || speechText == "knox"{
                speechAction = .nox
            }
        }
    }
}

#Preview {
    ModalView(isRecording: .constant(false), color: .constant(.gray), speechText: .constant(""), speechAction: .constant(.none))
}
