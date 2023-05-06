import UIKit
import Combine


func networkingRequest() -> Void {
    guard let url = URL(string: "https://mysite.com/mydata.json") else {
        return
    }

    // 1 It‘s crucial that you keep the resulting subscription; otherwise, it gets immediately canceled and the request never executes.
    let subscription = URLSession.shared

    // 2 You‘re using the overload of dataTaskPublisher(for:) that takes a URL as a parameter.
        .dataTaskPublisher(for: url)
        .sink(receiveCompletion: { completion in
            // 3 Make sure you always handle errors! Network connections are prone to failure.
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { data, response in
            // 4 The result is a tuple with both a Data object and a URLResponse.
            print("Retrieved data of size \(data.count), response = \(response)")
        })
}

networkingRequest()

