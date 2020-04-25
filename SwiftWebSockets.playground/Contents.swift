import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/// WebSocket delegate class to handle events when it connects and disconnects
class WebSocketDelegate: NSObject, URLSessionWebSocketDelegate {
  func urlSession(_ session: URLSession,
                  webSocketTask: URLSessionWebSocketTask,
                  didOpenWithProtocol protocol: String?) {
    print("WebSocket did connect")
    send()
    receive()
  }
  
  func urlSession(_ session: URLSession,
                  webSocketTask: URLSessionWebSocketTask,
                  didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                  reason: Data?) {
    print("WebSocket did disconnect \(closeCode)")
  }
}

let webSocketDelegate = WebSocketDelegate()
let session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())

let url = URL(string: "wss://echo.websocket.org")!

// Crate the WebSocket task
let webSocketTask = session.webSocketTask(with: url)

/// Receive messages from WebSocket
func receive() {
  webSocketTask.receive { result in
    switch result {
    case .success(let message):
      switch message {
      case .data(let data):
        print("Data received \(data)")
      case .string(let text):
        print("Text received \(text)")
      }
    case .failure(let error):
      print("Error when receiving \(error)")
    }
    
    // Need to call in recursion
    // otherwise we won't receive new messages
    receive()
  }
}

/// Send messages with WebSocket
func send() {
  webSocketTask.send(.string("Hello")) { error in
    if let error = error {
      print("Error when sending a message \(error)")
    }
  }
}

// Connecting to the WebSocket
webSocketTask.resume()
