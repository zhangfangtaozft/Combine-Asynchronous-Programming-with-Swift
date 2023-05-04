import Combine
import SwiftUI
import PlaygroundSupport

let valuesPertsecond = 1.0
let collectTimeStride = 4
let collectMaxCount = 2

// 1 Set up a source publisher — a subject that will relay the values a timer emits.
let sourcePublisher = PassthroughSubject<Date, Never>()

// 2 Create a collectedPublisher which collects values it receives during strides of collectTimeStride using the collect operator. The operator emits these groups of values as arrays on the specified scheduler: DispatchQueue.main.
let collectedPublisher = sourcePublisher.collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
    .flatMap { dates in dates.publisher }
let collectedPublisher2 = sourcePublisher
    .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
    .flatMap { dates in dates.publisher }

let subscription = Timer.publish(every: 1.0 / valuesPertsecond, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)

let sourceTimeline = TimelineView(title: "Emitted values:")
let collectionTimeline = TimelineView(title: "Collected values (every \(collectTimeStride)s):")
let collectedTimeline2 = TimelineView(title: "Collected values (at most \(collectMaxCount) every \(collectTimeStride)s):")

let view = VStack(spacing: 40) {
    sourceTimeline
    collectionTimeline
    collectedTimeline2
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 375, height: 600))


sourcePublisher.displayEvents(in: sourceTimeline)
collectedPublisher.displayEvents(in: collectionTimeline)
collectedPublisher2.displayEvents(in: collectedTimeline2)
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

