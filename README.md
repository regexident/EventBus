![jumbotron](jumbotron.png)
# EventBus

**EventBus** is a safe-by-default alternative to Cocoa's `NSNotificationCenter`. It provides a **type-safe API** that can **safely** be used from **multiple threads**. It automagically removes subscribers when they are deallocated.

EventBus is to **one-to-many notifications** what a `Delegate` is to one-to-one notifications.

![screencast](screencast.gif)

## Usage

### Simple Notifications:

Let's say you have a lottery that's supposed to notify all its participating players every time a new winning number is drawn:

```swift
import EventBus

protocol LotteryDraw {
    func didDraw(number: Int, in: Lottery)
}

class Lottery {
    private let eventBus = EventBus()
    
    func add(player: LottoPlayer) {
    	self.eventBus.add(subscriber: player, for: LotteryDraw.self)
    }
    
    func draw() {
        let winningNumber = arc4random()
        self.eventBus.notify(ValueChange.self) { subscriber in
            subscriber.didDraw(number: Int(winningNumber), in: self)
        }
    }
}

class LottoPlayer : LotteryDraw {
    func didDraw(number: Int, in: Lottery) {
        if number == 123456 { print("Hooray!") }
    }
}
```

### Complex Notifications:

Nice, but what if you would like to group a set of **semantically related notifications** (such as different stages of a process) into a common protocol? No problem! Your protocol can be of **arbitrary complexity**.

Consider this simple key-value-observing scenario:

```swift
import EventBus

protocol ValueChange {
    func willChangeValue(of: Publisher, from: Int, to: Int)
    func didChangeValue(of: Publisher, from: Int, to: Int)
}

class Publisher {
    private let eventBus = EventBus()
    
    var value: Int {
        willSet {
        	  self.eventBus.notify(ValueChange.self) { subscriber in
                subscriber.willChange(value: self.value, to: newValue)
            }
        }
        didSet {
            self.eventBus.notify(ValueChange.self) { subscriber in
                subscriber.didChange(value: oldValue, to: self.value)
            }
        }
    }
    
    func add(subscriber: ValueChange) {
    	self.eventBus.add(subscriber: subscriber, for: ValueChange.self)
    }
}

class Subscriber : ValueChange {
    func willChangeValue(of: Publisher, from: Int, to: Int) {
        print("\(of) will change value from \(from) to \(to).")
    }
    
    func didChangeValue(of: Publisher, from: Int, to: Int) {
        print("\(of) did change value from \(from) to \(to).")
    }
}
```

## Installation

The recommended way to add **EventBus** to your project is via [Carthage](https://github.com/Carthage/Carthage):

    github 'regexident/EventBus'

## License

**EventBus** is available under a **modified BSD-3 clause license**. See the `LICENSE` file for more info.
