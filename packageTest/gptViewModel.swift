//
//  gptModel.swift
//  packageTest
//
//  Created by CHANG JIN LEE on 2023/07/10.
//

import Foundation


class gptViewModel: ObservableObject {

    @Published var responseMessage = ""

    @MainActor func setMessage(value: String) {
        responseMessage.append(value)
    }

    @MainActor func getMessage() -> String {
        return responseMessage
    }

}
