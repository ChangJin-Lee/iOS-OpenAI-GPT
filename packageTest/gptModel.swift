//
//  gptModel.swift
//  packageTest
//
//  Created by CHANG JIN LEE on 2023/07/10.
//

import Foundation
import OpenAI

// MARK: - Model
struct AIChat: Codable {
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
    var model: String
    var userAvatarUrl: String
}

class ChatGPT: ObservableObject {

    @MainActor
    func queryGPT(prompts: String, completion: @escaping (String) -> Void) {
        let configuration = OpenAI.Configuration(token: "", organizationIdentifier: "", timeoutInterval: 60.0)
        let openAI = OpenAI(configuration: configuration)
        let customPrompt = prompts

        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: customPrompt)])

        openAI.chatsStream(query: query) { partialResult in
            print("data:")
            print(partialResult)
            switch partialResult {
            case .success(let result):
                if let res = result.choices.first?.delta.content{
                    DispatchQueue.main.async {
                        completion(res)
                    }
                }
            case .failure(let error):
                print(error)
                let errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    completion(errorMessage)
                }
            }
        } completion: { error in
            print(error ?? "Unknown Error.")
            if let errorMessage = error?.localizedDescription {
                DispatchQueue.main.async {
                    completion(errorMessage)
                }
            }
        }
    }

}
