import UIKit
import Combine

example(of: "create a Blackjack card dealer") {
    let dealHand = PassthroughSubject<Hand, HandError>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = 52
        var hand = Hand()
        
        for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        if hand.points > 21 {
            dealHand.send(completion: .failure(.busted))
        } else {
            dealHand.send(hand)
        }
    }
    // Add subscription to dealtHand here
    _ = dealHand.sink(receiveCompletion: {
        if case let .failure(error) = $0 {
            print(error)
        }
    }, receiveValue: { hand in
        print(hand.cardString, "for", hand.points, "points")
    })
    deal(3)
}
