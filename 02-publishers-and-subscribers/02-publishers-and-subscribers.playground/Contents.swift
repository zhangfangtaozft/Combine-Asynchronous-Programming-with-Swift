import Foundation
import Combine
import _Concurrency

var subscriptions = Set<AnyCancellable>()
/*
example(of: "Publisher") {
    // 1 Create a notification name.
    let myNotification = Notification.Name("MyNotification")
    
    // 2 Access NotificationCenter’s default instance, call its publisher(for:object:) method and assign its return value to a local constant.
    let publisher = NotificationCenter.default.publisher(for: myNotification, object: nil)
    
    // 3 Get a handle to the default notification center.
    let center = NotificationCenter.default
    
    // 4 Create an observer to listen for the notification with the name you previously created.
    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in
        print("Notification received!")
    }
    
    // 5 Post a notification with that name.
    center.post(name: myNotification, object: nil)
    
    // 6 Remove the observer from the notification center.
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    
    let publisher = center.publisher(for: myNotification)
    
    // 1 Create a subscription by calling sink on the publisher.
    let subscription = publisher.sink{ _ in
        print("Notification received from a publisher!")
    }
    
    // 2 Post the notification.
    center.post(name: myNotification, object: nil)
    
    // 3 Cancel the subscription.
    subscription.cancel()
}

example(of: "Just") {
    // 1 Create a publisher using Just, which lets you create a publisher from a single value.
    let just = Just("Hello world")
    
    // 2 Create a subscription to the publisher and print a message for each received event.
    _ = just.sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })
    print("------")
    _ = just.sink(receiveCompletion: {
        print("Received completion (another)", $0)
    }, receiveValue: {
        print("Received value (another)", $0)
    })
    
    let myRange = (0...3)
         _ = myRange.publisher
             .sink(receiveCompletion: { print ("completion: \($0)") },
                   receiveValue: { print ("value: \($0)") })
}

example(of: "assign(to:on:)") {
    // 1 Define a class with a property that has a didSet property observer that prints the new value.(使用具有打印新值的 didSet 属性观察器的属性定义一个类。)
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    // 2 Create an instance of that class.
    let object = SomeObject()
    
    // 3 Create a publisher from an array of strings.
    let publisher = ["hello", "World","!"].publisher
    
    // 4 Subscribe to the publisher, assigning each value received to the value property of the object.
    _ = publisher.assign(to: \.value, on: object)
}

example(of: "assign(to:)") {
   // 1 Define and create an instance of a class with a property annotated with the @Published property wrapper, which creates a publisher for value in addition to being accessible as a regular property.
    class SomeObject {
        @Published var value = 0
    }
    
    let object = SomeObject()
    
    // 2 Use the $ prefix on the @Published property to gain access to its underlying publisher, subscribe to it, and print out each value received.
    object.$value.sink {
        print($0)
    }
    
    // 3 Create a publisher of numbers and assign each value it emits to the value publisher of object. Note the use of & to denote an inout reference to the property.
    (0..<10).publisher.assign(to: &object.$value)
}


example(of: "Custom Subscriber") {
    // 1 Create a publisher of integers via the range’s publisher property.
    let publisher = (1...6).publisher
    
    // 2 Define a custom subscriber, IntSubscriber.
    final class IntSubscriber: Subscriber {
        // 3 Implement the type aliases to specify that this subscriber can receive integer inputs and will never receive errors.
        typealias Input = Int
        typealias Failure = Never
        
        // 4 Implement the required methods, beginning with receive(subscription:), called by the publisher; and in that method, call .request(_:) on the subscription specifying that the subscriber is willing to receive up to three values upon subscription.
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        // 5 Print each value as it’s received and return .none, indicating that the subscriber will not adjust its demand; .none is equivalent to .max(0).
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            return .none
        }
        
        // 6 Print the completion event.
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}


example(of: "Future") {
    print("Original")
    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        Future<Int, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(integer + 1))
            }
        }
    }
    
    // 1
    let future = futureIncrement(integer: 1, afterDelay: 2)
    
    // 2
    future.sink(receiveCompletion: { print($0) }, receiveValue: { print($0) }).store(in: &subscriptions)
    
    future.sink(receiveCompletion: { print("Second", $0) }, receiveValue: { print("Second", $0) }).store(in: &subscriptions)
}


example(of: "PassthroughSubject") {
    // 1 Define a custom error type.
    enum MyError: Error {
        case test
    }
    
    // 2 Define a custom subscriber that receives strings and MyError errors.
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Receive value", input)
            
            // 3 Adjust the demand based on the received value.
            return input == "world" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Receive completion", completion)
        }
    }
    // 4 Create an instance of the custom subscriber.
    let subscriber = StringSubscriber()
    
    // 5 Creates an instance of a PassthroughSubject of type String and the custom error type you defined.
    let subject = PassthroughSubject<String, MyError>()
    
    // 6 Subscribes the subscriber to the subject.
    subject.subscribe(subscriber)
    
    // 7 Creates another subscription using sink.
    let subscrition = subject.sink(receiveCompletion: { completion in
        print("Received completion (sink)", completion)
    }, receiveValue: { value in
        print("Received value (sink)", value)
    })
    
    subject.send("Hello")
    subject.send("World")
    
    // 8
    subscrition.cancel()
    
    // 9
    subject.send("Still there?")
    
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")
}
 


example(of: "CurrentValueSubject") {
    // 1 Create a subscriptions set.
    var subscriptions = Set<AnyCancellable>()
    
    // 2 Create a CurrentValueSubject of type Int and Never. This will publish integers and never publish an error, with an initial value of 0.
    let subject = CurrentValueSubject<Int, Never>(0)
    
    // 3 Create a subscription to the subject and print values received from it.
    subject.print().sink(receiveValue: { print($0) }).store(in: &subscriptions)
    // 4 Store the subscription in the subscriptions set (passed as an inout parameter instead of a copy).
    
    subject.send(1)
    subject.send(2)
    print(subject.value)
    subject.value = 3
    print(subject.value)
    
    subject.sink(receiveValue: { print("Second subscription:", $0) }).store(in: &subscriptions)
    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            
            switch input {
            case 1:
                return .max(2)
            case 2:
                return .max(1)
            default:
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}
 */

example(of: "Type erasure") {
    // 1 Create a passthrough subject.
    let subject = PassthroughSubject<Int, Never>()
    
    // 2 Create a type-erased publisher from that subject.
    let publisher = subject.eraseToAnyPublisher()
    
    // 3 Subscribe to the type-erased publisher.
    publisher.sink(receiveValue: { print($0) }).store(in: &subscriptions)
    
    // 4 Send a new value through the passthrough subject.
    subject.send(0)
    
//    publisher.send(1)
}

example(of: "async/await") {
    // 1
    let subject = CurrentValueSubject<Int, Never>(0)
    
    // 2
    Task {
        for await element in subject.values {
            print("Element: \(element)")
        }
        print("Completed.")
    }
    
    // 3
    subject.send(1)
    subject.send(2)
    subject.send(3)
    
    subject.send(completion: .finished)
}
