import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "prepend(Output...)") {
    // 1
    let publisher = [3, 4].publisher
    
    // 2
    publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Sequence)") {
    // 1
    let publisher = [5, 6, 7].publisher
    
    // 2
    publisher
        .prepend([3, 4])
        .prepend(Set(1...2))
        .prepend(stride(from: 6, to: 11, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher)") {
    // 1
    let publisher1 = [3, 4].publisher
    let publisher2 = [1, 2].publisher
    let publisher3 = [5, 6].publisher
    // 2
    publisher1
        .prepend(publisher2)
        .prepend(publisher3)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher) #2") {
    // 1
    let publisher1 = [3, 4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    
    // 2
    publisher1.prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 3
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

example(of: "append(Output...)") {
    // 1
    let publisher = [1].publisher
    // 2
    publisher
        .append(2, 3)
        .append(4)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Output...) #2") {
    // 1
    let publisher = PassthroughSubject<Int, Never>()
    
    publisher
        .append(3, 4)
        .append(5)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 2
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}

example(of: "append(Sequence)") {
    // 1
    let publisher = [1, 2, 3].publisher
    
    publisher
        .append([4, 5])
        .append(Set([6, 7]))
        .append(stride(from: 8, to: 11, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Publisher)") {
    // 1
    let publisher1 = [1, 2].publisher
    let publisher2 = [3, 4].publisher
    
    // 2
    publisher1.append(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "switchToLatest") {
    // 1 Create three PassthroughSubjects that accept integers and no errors.
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    
    // 2 Create a second PassthroughSubject that accepts other PassthroughSubjects. For example, you can send publisher1, publisher2 or publisher3 through it.
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    
    // 3 Use switchToLatest on your publishers. Now, every time you send a different publisher through the publishers subject, you switch to the new one and cancel the previous subscription.
    publishers.switchToLatest().sink(receiveCompletion: { _ in print("Completed!") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 4 Send publisher1 to publishers and then send 1 and 2 to publisher1.
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    // 5 Send publisher2, which cancels the subscription to publisher1. You then send 3 to publisher1, but it’s ignored, and send 4 and 5 to publisher2, which are pushed through because there is an active subscription to publisher2.
    
    publishers.send(publisher2)
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)
    
    // 6 Send publisher3, which cancels the subscription to publisher2. As before, you send 6 to publisher2 and it’s ignored, and then send 7, 8 and 9, which are pushed through the subscription to publisher3.
    publishers.send(publisher3)
    publisher3.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    // 7 Finally, you send a completion event to the current publisher, publisher3, and another completion event to publishers. This completes all active subscriptions.
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}
/*
example(of: "switchToLatest - Network Request") {
    let url = URL(string: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F09%2F20210609081952_51ef5.thumb.1000_0.jpg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1685645412&t=dcc49a12bf4d54ce0e8df63696bef2a0")!
    
    // 1
    func getImage() -> AnyPublisher<UIImage?, Never> {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .print("image")
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    // 2
    let taps = PassthroughSubject<Void, Never>()
    taps
        .map { _ in getImage() } // 3
        .switchToLatest() // 4
        .sink(receiveValue: { _ in })
        .store(in: &subscriptions)
    
    // 5
    taps.send()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        taps.send()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
        taps.send()
    }
}
*/

example(of: "merge(with:)") {
    // 1 Create two PassthroughSubjects that accept and emit integer values and will not emit an error.
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    
    // 2 Merge publisher1 with publisher2, interleaving the emitted values from both. Combine offers overloads that let you merge up to eight different publishers.
    publisher1.merge(with: publisher2)
        .sink(receiveCompletion: { _ in print("Completed") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 3 You add 1 and 2 to publisher1, then add 3 to publisher2, then add 4 to publisher1 again and finally add 5 to publisher2.
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send(3)
    
    publisher1.send(4)
    publisher2.send(5)
    
    // 4 You send a completion event to both publisher1 and publisher2.
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

example(of: "combineLatest") {
    // 1 Create two PassthroughSubjects. The first accepts integers with no errors, while the second accepts strings with no errors.
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    // 2 Combine the latest emissions of publisher2 with publisher1. You may combine up to four different publishers using different overloads of combineLatest.
    publisher1
        .combineLatest(publisher2)
        .sink(receiveCompletion: { _ in print("Completed") }, receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    
    // 3 Send 1 and 2 to publisher1, then "a" and "b" to publisher2, then 3 to publisher1 and finally "c" to publisher2.
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send("a")
    publisher2.send("b")
    
    publisher1.send(3)
    
    publisher2.send("c")
    
    publisher1.send(4)
    
    // 4 Send a completion event to both publisher1 and publisher2.
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

example(of: "zip") {
    // 1 Create two PassthroughSubjects, where the first accepts integers and the second accepts strings. Both cannot emit errors.
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    // 2 Zip publisher1 with publisher2, pairing their emissions once they each emit a new value.
    publisher1
        .zip(publisher2)
        .sink(receiveCompletion: { _ in print("Completed")}, receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    
    // 3 Send 1 and 2 to publisher1, then "a" and "b" to publisher2, then 3 to publisher1 again, and finally "c" and "d" to publisher2.
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher2.send("d")
    publisher1.send(5)
    publisher1.send(7)
    
    // 4 Complete both publisher1 and publisher2.
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

// Copyright (c) 2021 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
