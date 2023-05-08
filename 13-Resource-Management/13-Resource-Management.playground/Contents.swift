import UIKit
import Combine

//let shared = URLSession
//    .shared
//    .dataTaskPublisher(for: URL(string: "https://www.bing.com")!)
//    .map(\.data)
//    .print("shared")
//    .share()
//
//print("subscription first")
//
//let subscription1 = shared
//    .sink(receiveCompletion: { _ in }, receiveValue: {
//    print("subscription1 received: '\($0)'")
//})
//
//print("subscrbing second")

//let subscription2 = shared
//    .sink(receiveCompletion: { _ in }, receiveValue: {
//        print("subscription2 received: '\($0)'")
//    })
//var subscription2: AnyCancellable? = nil
//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//    print("subscription second")
//    subscription2 = shared
//        .sink(receiveCompletion: {
//            print("subscription2 completion: \($0)")
//        }, receiveValue: {
//            print("subscription2 received: '\($0)'")
//        })
//}

//// 1 Prepares a subject, which relays the values and completion event the upstream publisher emits.
//let subject = PassthroughSubject<Data, URLError>()
//
//// 2 Prepares the multicasted publisher, using the above subject.
//let multicasted = URLSession
//    .shared
//    .dataTaskPublisher(for: URL(string: "https://www.bing.com")!)
//    .map(\.data)
//    .print("multicast")
//    .multicast(subject: subject)
//
//// 3 Subscribes to the shared — i.e., multicasted — publisher, like earlier in this chapter.
//let subscription1 = multicasted
//    .sink(receiveCompletion: { _ in }, receiveValue: {
//        print("subscription1 received: '\($0)'")
//    })
//
//let subscription2 = multicasted
//    .sink(receiveCompletion: { _ in }, receiveValue: {
//        print("subscription2 received: '\($0)'")
//    })
//
//// 4 Instructs the publisher to connect to the upstream publisher.
//let cancellable = multicasted.connect()

// Future
// 1 Provides a function simulating work (possibly asynchronous) performed by the Future.
func performSomeWork() throws -> Int {
    print("Performing some work and returning a result")
    return 5
}

// 2 Creates a new Future. Note that the work starts immediately without waiting for subscribers.
let future = Future<Int, Error> { fulfill in
    do {
        let result = try performSomeWork()
        // 3 In case the work succeeds, it fulfills the Promise with the result.
        fulfill(.success(result))
    } catch {
        // 4 If the work fails, it passes the error to the Promise.
        fulfill(.failure(error))
    }
}
                
print("Subscribing to future...")

// 5 Subscribes once to show that we receive the result.
let subscription1 = future
    .sink(receiveCompletion: { _ in
        print("subscription1 completed")
    }, receiveValue: {
        print("subscription1 received: '\($0)'")
    })

// 6 Subscribes a second time to show that we receive the result too without performing the work twice.
let subscription2 = future
    .sink(receiveCompletion: { _ in
        print("subscription2 completed")
    }, receiveValue: {
        print("subscription2 received: '\($0)'")
    })
