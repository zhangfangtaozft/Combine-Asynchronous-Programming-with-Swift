import Cocoa
import Combine

let subscription = (1...3)
    .publisher
    .print("------publisher------")
    .sink { _ in }
class TimeLogger: TextOutputStream {
    private var previous = Date()
    private let formatter = NumberFormatter()
    
    init() {
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
    }
    
    func write(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        print("测试+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
        previous = now
    }
}

let subscription2 = (1...3).publisher
    .print("publisher", to: TimeLogger())
    .handleEvents(receiveSubscription: { _ in
        print("Network request will start")
    }, receiveOutput: { _ in
        print("Network request data received")
    }, receiveCancel: {
        print("Network request cancelled")
    })
    .breakpoint(receiveOutput: { value in
        return value > 10 && value < 40
    })
    .sink { _ in }

// performing side effects
let request = URLSession
    .shared
    .dataTaskPublisher(for: URL(string: "https://baidu.com/")!)

request
    .sink(receiveCompletion: { completion in
        print("Sink received completion: \(completion)")
    }, receiveValue: { (data, _) in
        print("Sink received data: \(data)")
    })
    
//let subscription3 = request
//    .print("-------subscription3------")
//    .handleEvents()
