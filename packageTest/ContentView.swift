//
//  ContentView.swift
//  gptKit
//
//  Created by CHANG JIN LEE on 2023/07/07.
//

import SwiftUI
struct ContentView: View {

    @State private var textInput: String = ""
    @State private var answer: String = ""
    @State private var GPT =  ChatGPT()

    var body: some View {
        Spacer()
            .frame(height: 30)
        TextField("Enter text", text: $textInput)
                       .padding()
                       .textFieldStyle(RoundedBorderTextFieldStyle())
        Button{
            answer += "\n\n"
            GPT.queryGPT(prompts: textInput){ word in
                answer += word
                print(word)
            }
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 100, height: 30)
                Text("Button")
                    .foregroundColor(.white)
            }
        }
        ScrollView{

            Spacer()

            Text(answer)
                .padding(.horizontal, 50)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

