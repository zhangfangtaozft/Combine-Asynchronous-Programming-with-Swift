import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Challenge: Filter all the things") {
    let numbers = (1...100).publisher
    
    numbers.dropFirst(50)
        .prefix(20)
        .filter { $0 % 2 == 0 }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
