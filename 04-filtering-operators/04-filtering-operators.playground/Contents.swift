import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
    // 1
    let numbers = (1...10).publisher
    
    // 2
    numbers.filter { $0.isMultiple(of: 3) }
        .sink(receiveValue: { n in
            print("\(n) is a multiple of 3!")
        })
        .store(in: &subscriptions)
}

example(of: "removeDuplicates") {
    // 1 
    let words = "hey hey there! want to listen to mister mister ?".components(separatedBy: " ")
        .publisher
    // 2
    words.removeDuplicates()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
example(of: "compactMap") {
    // 1 Create a publisher that emits a finite list of strings.
    let strings = ["a", "1.24", "3","def", "45", "0.23"].publisher
    
    // 2 Use compactMap to attempt to initialize a Float from each individual string. If Float’s initializer doesn’t know how to convert the provided string, it returns nil. Those nil values are automatically filtered out by the compactMap operator.
    strings.compactMap { Float($0) }
        .sink(receiveValue: {
            // 3 Only print strings that have been successfully converted to Floats.
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "ignoreOutput", action: {
    // 1
    let numbers = (1...10_000).publisher
    
    // 2
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0)
        })
        .store(in: &subscriptions)
})

example(of: "first(where:)") {
    // 1
    let numbers = (1...9).publisher
    
    // 2
    numbers
        .print("number")
        .first(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
}

example(of: "last(where:)") {
    // 1
    let numbers = PassthroughSubject<Int, Never>()
    
    // 2
    numbers.last(where: { $0 % 4 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)
}

example(of: "dropFirst") {
    // 1
    let numbers = (1...10).publisher
    
    // 2
    numbers
        .dropFirst(8)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "drop(while:)") {
    // 1
    let numbers = (1...10).publisher
    // 2
    numbers.drop(while: { $0 % 5 != 0 })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "drop(while:)") {
    // 1
    let numbers = (1...10).publisher
    // 2
    numbers.drop(while: {
        print("X")
        return $0 % 5 != 0
    })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "drop(untilOutputFrom:)") {
    // 1 Create two PassthroughSubjects that you can manually send values through. The first is isReady while the second represents taps by the user.
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    // 2 Use drop(untilOutputFrom: isReady) to ignore any taps from the user until isReady emits at least one value.
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 3 Send five “taps” through the subject, just like in the diagram above. After the third tap, you send isReady a value.
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 3 {
            isReady.send()
        }
    }
}

example(of: "prefix") {
    // 1
    let numbers = (1...10).publisher
    
    // 2
    numbers
        .prefix(2)
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prefix(while:)") {
    // 1
    let numbers = (1...10).publisher
    
    // 2
    numbers
        .prefix(while: { $0 < 3 })
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prefix(untilOutputFrom:)") {
    // 1
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    // 2
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 3
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 2 {
            isReady.send()
        }
    }
}
/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
