//
//  ContentView.swift
//  gptKit
//
//  Created by CHANG JIN LEE on 2023/07/07.
//

import SwiftUI
import OpenAI

struct ContentView: View {
    @State var queryComment = ""
    @State var queryAnswer  = ""
    let openAI = OpenAI(apiToken: "")
    let zeddQueue = DispatchQueue(label: "zedd", attributes: .concurrent)

    var body: some View {
        VStack {
            Text("gpt querry : \(queryComment)")

            Spacer()
                .frame(height: 60)

            Text("gpt answer : \(queryAnswer)")
                .font(.headline)

            Button{
                MyGpt().queryGPT()
            }label: {
                Text("button")
            }

            Spacer()
                .frame(height: 10)

            Button{

                print("")

            }label:{
                Text("button2")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MyGpt {
    func queryGPT() {
        let configuration = OpenAI.Configuration(token: "", organizationIdentifier: "", timeoutInterval: 60.0)
        let openAI = OpenAI(configuration: configuration)
        let customPrompt = """
**( 영수증**

**[매장명] 중앙씸닭**

**[사업자] 278-01-00667**

**[주**

**소] 경북 안동시 번염1길 51 (서부동)**

**[대표자] 임지훈**

**[TEL] 054-855-7272**

**[매출일] 2023-07-02 12:47:00 2**

- **이-임시요**

**[영수중] 20230424-01-2902**

**단 기 수량**

**금액**

**안동찜닭 (보통맛)**

**000002**

**순살찜닭(보통맛)**

**000027**

**공기밥**

**000015**

**음료수**

**000020**

**32,000**

**~**

**36,000**

- ****

**1,000**

**ㆀ**

**2,000**

**~**

**합계금액**

**부가세 과세물품가액**

**과**

- ****

**쇼니 쇼니**

**이미 이니**

**힘**

**OnC**

**64,000**

**36,000**

**8,000**

**4,000**

**112,000**

**101,821**

**10,179**

**112,000**

**112,000**

**조**

**112,000**

- **물품반품시 본 얼수증을 원히 시장이어**

**주시기 바랍니다.**
"""
        var stringArray = ""
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: customPrompt+"\n 이거를 정리해줘")])


        openAI.chatsStream(query: query) { partialResult in
            switch partialResult {
            case .success(let result):
                if let res = result.choices.first?.delta.content{
                    stringArray.append(res)
                }
            case .failure(let error):
                print(error)
            }
        } completion: { error in
            print(stringArray)
        }
    }

}
