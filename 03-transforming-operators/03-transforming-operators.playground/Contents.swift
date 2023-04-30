import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher
        .collect(2)
        .sink(receiveCompletion: { print("receiveCompletion:\($0)") }, receiveValue: { print("receiveValue:\($0)") })
        .store(in: &subscriptions)
}

example(of: "map") {
    // 1 Create a number formatter to spell out each number.
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut

    // 2 Create a publisher of integers.
    [123, 4, 56, 2389471].publisher
    // 3 Use map, passing a closure that gets upstream values and returns the result of using the formatter to return the number’s spelled out string.
        .map {
            formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "mapping key paths") {
    // 1 Create a publisher of Coordinates that will never emit an error.
    let publisher = PassthroughSubject<Coordinate, Never>()
    
    // 2 Begin a subscription to the publisher.
    publisher
    
    // 3 Map into the x and y properties of Coordinate using their key paths.
        .map(\.x, \.y)
        .sink(receiveValue: { x, y in
            // 4 Print a statement that indicates the quadrant of the provide x and y values.
            print("The coordinate at (\(x), \(y)) is in quadrant",
                  quadrantOf(x: x, y: y)
            )
        })
        .store(in: &subscriptions)
    // 5 Send some coordinates through the publisher.
    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}

example(of: "tryMap") {
    // 1 Create a publisher of a string representing a directory name that does not exist.
    Just("Directory name that does not exist")
    // 2 Use tryMap to attempt to get the contents of that nonexistent directory.
        .tryMap { try
            FileManager.default.contentsOfDirectory(atPath: $0)
        }
    // 3 Receive and print out any values or completion events.
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "flatMap") {
    // 1 Define a function that takes an array of integers, each representing an ASCII code, and returns a type-erased publisher of strings that never emits errors.
    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
        // 2 Create a Just publisher that converts the character code into a string if it’s within the range of 0.255, which includes standard and extended printable ASCII characters.
        Just(codes.compactMap { code in
            guard (32...255).contains(code) else { return nil }
            return String(UnicodeScalar(code) ?? " ")
        }
        // 3 Join the strings together.
            .joined()
        )
        // 4 Type erase the publisher to match the return type for the fuction.
        .eraseToAnyPublisher()
    }
    
    // 5 Create a secret message as an array of ASCII character codes, convert it to a publisher, and collect its emitted elements into a single array.
    [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]
        .publisher
        .collect()
    // 6 Use flatMap to pass the array element to your decoder function.
        .flatMap(decode)
    // 7 Subscribe to the elements emitted by the pubisher returned by decode(_:) and print out the values.
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceNil") {
    // 1 Create a publisher from an array of optional strings.
    ["A", nil, "C"].publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "_")
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    // 1 Create an empty publisher that immediately emits a completion event.
    let empty = Empty<Int, Never>()
    
    // 2 Subscribe to it, and print received events.
    empty
        .replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "scan") {
    // 1 Create a computed property that generates a random integer between -10 and 10.
    var dailyGainLoss: Int { .random(in: -10...10) }
    
    // 2 Use that generator to create a publisher from an array of random integers representing fictitious daily stock price changes for a month.
    let august2019 = (0..<22)
        .map { _ in dailyGainLoss }
        .publisher
    // 3 Use scan with a starting value of 50, and then add each daily change to the running stock price. The use of max keeps the price non-negative — thankfully stock prices can’t fall below zero!
    august2019
        .scan(50) { latest, current in
            max(0, latest + current)
        }
        .sink(receiveValue: {_ in })
        .store(in: &subscriptions)
}
