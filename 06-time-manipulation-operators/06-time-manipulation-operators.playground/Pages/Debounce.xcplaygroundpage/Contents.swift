import Combine
import SwiftUI
import PlaygroundSupport

// 1 Create a source publisher which will emit strings.
let subject = PassthroughSubject<String, Never>()

// 2 Use debounce to wait for one second on emissions from subject. Then, it will send the last value sent in that one-second interval, if any. This has the effect of allowing a max of one value per second to be sent.
let debounced = subject.debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)

// 3 You are going to subscribe multiple times to debounced. To guarantee consistency of the results, you use share() to create a single subscription point to debounce that will show the same results at the same time to all subscribers.
    .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")

let view = VStack(spacing: 100) {
    subjectTimeline
    debouncedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 375, height: 600))

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)


let subscription1 = subject
    .sink { string in
        print("+\(deltaTime)s: Subject emitted: \(string)")
    }

let subscription2 = debounced
    .sink { string in
        print("+\(deltaTime)s: Debounced emitted: \(string)")
    }
subject.feed(with: typingHelloWorld)



//: [Next](@next)
/*:
 Copyright (c) 2021 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

