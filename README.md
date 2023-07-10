# iOS-OpenAI-GPT

### Chats

Using the OpenAI Chat API, you can build your own applications with `gpt-3.5-turbo` to do things like:

* Draft an email or other piece of writing
* Write Python code
* Answer questions about a set of documents
* Create conversational agents
* Give your software a natural language interface
* Tutor in a range of subjects
* Translate languages
* Simulate characters for video games and much more

**Request**

```swift
 struct ChatQuery: Codable {
     /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
     public let model: Model
     /// The messages to generate chat completions for
     public let messages: [Chat]
     /// A list of functions the model may generate JSON inputs for.
     public let functions: [ChatFunctionDeclaration]?
     /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and  We generally recommend altering this or top_p but not both.
     public let temperature: Double?
     /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
     public let topP: Double?
     /// How many chat completion choices to generate for each input message.
     public let n: Int?
     /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
     public let stop: [String]?
     /// The maximum number of tokens to generate in the completion.
     public let maxTokens: Int?
     /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
     public let presencePenalty: Double?
     /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
     public let frequencyPenalty: Double?
     ///Modify the likelihood of specified tokens appearing in the completion.
     public let logitBias: [String:Int]?
     /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
     public let user: String?
}
```

**Response**

```swift
struct ChatResult: Codable, Equatable {
    public struct Choice: Codable, Equatable {
        public let index: Int
        public let message: Chat
        public let finishReason: String
    }
    
    public struct Usage: Codable, Equatable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
    }
    
    public let id: String
    public let object: String
    public let created: TimeInterval
    public let model: Model
    public let choices: [Choice]
    public let usage: Usage
}
```

**Example**

```swift
let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: "who are you")])
let result = try await openAI.chats(query: query)
```

```
(lldb) po result
▿ ChatResult
  - id : "chatcmpl-6pwjgxGV2iPP4QGdyOLXnTY0LE3F8"
  - object : "chat.completion"
  - created : 1677838528.0
  - model : "gpt-3.5-turbo-0301"
  ▿ choices : 1 element
    ▿ 0 : Choice
      - index : 0
      ▿ message : Chat
        - role : "assistant"
        - content : "\n\nI\'m an AI language model developed by OpenAI, created to provide assistance and support for various tasks such as answering questions, generating text, and providing recommendations. Nice to meet you!"
      - finish_reason : "stop"
  ▿ usage : Usage
    - prompt_tokens : 10
    - completion_tokens : 39
    - total_tokens : 49
```

#### Chats Streaming

Chats streaming is available by using `chatStream` function. Tokens will be sent one-by-one.

**Closures**
```swift
openAI.chatsStream(query: query) { partialResult in
    switch partialResult {
    case .success(let result):
        print(result.choices)
    case .failure(let error):
        //Handle chunk error here
    }
} completion: { error in
    //Handle streaming error here
}
```

**Combine**

```swift
openAI
    .chatsStream(query: query)
    .sink { completion in
        //Handle completion result here
    } receiveValue: { result in
        //Handle chunk here
    }.store(in: &cancellables)
```

**Structured concurrency**
```swift
for try await result in openAI.chatsStream(query: query) {
   //Handle result here
}
```

**Function calls**
```swift
let openAI = OpenAI(apiToken: "...")
// Declare functions which GPT-3 might decide to call.
let functions = [
  ChatFunctionDeclaration(
      name: "get_current_weather",
      description: "Get the current weather in a given location",
      parameters:
        JSONSchema(
          type: .object,
          properties: [
            "location": .init(type: .string, description: "The city and state, e.g. San Francisco, CA"),
            "unit": .init(type: .string, enumValues: ["celsius", "fahrenheit"])
          ],
          required: ["location"]
        )
  )
]
let query = ChatQuery(
  model: "gpt-3.5-turbo-0613",  // 0613 is the earliest version with function calls support.
  messages: [
      Chat(role: .user, content: "What's the weather like in Boston?")
  ],
  functions: functions
)
let result = try await openAI.chats(query: query)
```

Result will be (serialized as JSON here for readability):
```json
{
  "id": "chatcmpl-1234",
  "object": "chat.completion",
  "created": 1686000000,
  "model": "gpt-3.5-turbo-0613",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "function_call": {
          "name": "get_current_weather",
          "arguments": "{\n  \"location\": \"Boston, MA\"\n}"
        }
      },
      "finish_reason": "function_call"
    }
  ],
  "usage": { "total_tokens": 100, "completion_tokens": 18, "prompt_tokens": 82 }
}

```


Review [Chat Documentation](https://platform.openai.com/docs/guides/chat) for more info.
