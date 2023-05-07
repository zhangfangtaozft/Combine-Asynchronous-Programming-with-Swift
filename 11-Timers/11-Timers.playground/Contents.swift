import Cocoa
import Combine

//let runLoop = RunLoop.main
//
//let subscription = runLoop.schedule(after: runLoop.now, interval: .seconds(1), tolerance: .milliseconds(100)) {
//    print("Timer fired")
//}
//
//runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
//    subscription.cancel()
//}

// Timer
/*
 • On which RunLoop your timer attaches to. Here, the main thread‘s RunLoop.

 • In which run loop mode(s) the timer runs. Here, the default run loop mode.
 */
//let publisher = Timer.publish(every: 1.0, on: .main, in: .common)
//let publisher = Timer.publish(every: 1.0, on: .current, in: .common)

//let publisher = Timer
//    .publish(every: 1.0, on: .main, in: .common)
//    .autoconnect()
//
//let subscription = Timer
//    .publish(every: 1.0, on: .main, in: .common)
//    .autoconnect()
//    .scan(0) { counter, _ in counter + 1 }
//    .sink { counter in
//        print("Counter is  \(counter)")
//    }
let queue = DispatchQueue.main

// 1 Create a Subject you will send timer values to.
let source = PassthroughSubject<Int, Never>()

// 2 Prepare a counter. You‘ll increment it every time the timer fires.
var counter = 0

// 3 Schedule a repeating action on the selected queue every second. The action starts immediately.
let cancellable = queue.schedule(after: queue.now, interval: .seconds(1)) {
    source.send(counter)
    counter += 1
}

// 4 Subscribe to the subject to get the timer values.
let subscription = source.sink {
    print("Timer emitted \($0)")
}
