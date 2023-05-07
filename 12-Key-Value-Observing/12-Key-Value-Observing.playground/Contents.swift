import UIKit
import Combine

//let queue = OperationQueue()
//
//let subscription = queue.publisher(for: \.operationCount)
//    .sink {
//        print("Outstanding operations in queue: \($0)")
//    }

// 1 Create a class that conforms to the NSObject protocol. This is required for KVO.
//class TestObject: NSObject {
//    // 2 Mark any property you want to make observable as @objc dynamic.
//    @objc dynamic var integerProperty: Int = 0
//    @objc dynamic var stringproperty: String = ""
//    @objc dynamic var arrayproperty: [Float] = []
//}
//
//let obj = TestObject()
//
//// 3 Create and subscribe to a publisher observing the integerProperty property of obj.
//let subscription = obj.publisher(for: \.integerProperty, options: [.prior])
//    .sink {
//        print("integerProperty changes to \($0)")
//    }
//
//let subscription2 = obj.publisher(for: \.stringproperty)
//    .sink {
//        print("stringproperty changes to \($0)")
//    }
//
//let subscription3 = obj.publisher(for: \.arrayproperty)
//    .sink {
//        print("arrayProperity changes to \($0)")
//    }
//
//// 4 Update the property a couple times.
//obj.integerProperty = 100
//obj.integerProperty = 200
//
//obj.stringproperty = "Hello"
//obj.arrayproperty = [1.0]
//obj.stringproperty = "World"
//obj.arrayproperty = [1.0, 2.0]
//
//struct PureSwift {
//    let a: (Int, Bool)
//}
//
//dynamic var structProperty: PureSwift = .init(a: (0, false))
//

class MonitorObject: ObservableObject {
    @Published var someproperity = false
    @Published var someOtherProperity = ""
}

let object = MonitorObject()
let subscription = object.objectWillChange.sink {
    print("object will change")
}

object.someproperity = true
object.someOtherProperity = "Hello world"
