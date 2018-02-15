//
//  ViewController.swift
//  EventBus iOS
//
//  Created by Vincent Esche on 05/12/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import UIKit

import EventBus

protocol Event {
    func handle(after: TimeInterval)
}

class Subscriber {
    let eventSubscribable: EventSubscribable
    let view: UIView

    init(eventSubscribable: EventSubscribable, view: UIView) {
        self.eventSubscribable = eventSubscribable
        self.view = view

        self.eventSubscribable.add(subscriber: self, for: Event.self)
    }
}

extension Subscriber: Event {
    func handle(after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let backgroundColor = self.view.backgroundColor
            UIView.animate(withDuration: 0.25, animations: {
                self.view.backgroundColor = UIColor.red
            }, completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.view.backgroundColor = backgroundColor
                }
            })
        }
    }
}

@IBDesignable
class RoundedRectView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    func commonInit() {
        self.backgroundColor = UIColor(red: 0.2745, green: 0.5572, blue: 0.8976, alpha: 1.0)
        self.layer.cornerRadius = 10.0
    }
}

class ViewController: UIViewController {

    @IBOutlet var publisherView: RoundedRectView!
    @IBOutlet var eventBusView: RoundedRectView!
    @IBOutlet var subscriberViewTop: RoundedRectView!
    @IBOutlet var subscriberViewMiddle: RoundedRectView!
    @IBOutlet var subscriberViewBottom: RoundedRectView!
    @IBOutlet var diagramView: UIImageView!
    @IBOutlet var containerView: UIView!

    let eventBus: EventBus = .init(options: [.warnUnhandled])
    var timer: Timer!

    var subscribers: [Subscriber] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.subscribers = [
            Subscriber(eventSubscribable: eventBus, view: self.subscriberViewTop),
            Subscriber(eventSubscribable: eventBus, view: self.subscriberViewMiddle),
            Subscriber(eventSubscribable: eventBus, view: self.subscriberViewBottom),
        ]

        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.ping()
        }
        self.timer.fire()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func ping() {
        self.eventBus.notify(Event.self) { subscriber in
            subscriber.handle(after: 2.0)
        }

        self.emitSignal(color: UIColor.red, onPath: {
            let path = UIBezierPath()
            path.move(to: self.publisherView.center)
            path.addLine(to: self.eventBusView.center)
            return path
        }())

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
            self.emitSignal(color: UIColor.red, onPath: {
                let startFrame = self.eventBusView.frame
                let endFrame = self.subscriberViewTop.frame
                let startPoint = CGPoint(x: startFrame.maxX, y: startFrame.midY)
                let endPoint = CGPoint(x: endFrame.minX, y: endFrame.midY)
                let path = UIBezierPath()
                path.move(to: self.eventBusView.center)
                path.addLine(to: startPoint)
                path.addCurve(
                    to: startPoint.applying(.init(translationX: 10.0, y: -10.0)),
                    controlPoint1: startPoint.applying(.init(translationX: 5.0, y: 0.0)),
                    controlPoint2: startPoint.applying(.init(translationX: 10.0, y: -5.0))
                )
                path.addLine(to: startPoint.applying(.init(translationX: 10.0, y: -50.0)))
                path.addCurve(
                    to: endPoint,
                    controlPoint1: endPoint.applying(.init(translationX: -10.0, y: 5.0)),
                    controlPoint2: endPoint.applying(.init(translationX: -5.0, y: 0.0))
                )
                path.addLine(to: self.subscriberViewTop.center)
                return path
            }())
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.emitSignal(color: UIColor.red, onPath: {
                let path = UIBezierPath()
                path.move(to: self.eventBusView.center)
                path.addLine(to: self.subscriberViewMiddle.center)
                return path
            }())
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.emitSignal(color: UIColor.red, onPath: {
                let startFrame = self.eventBusView.frame
                let endFrame = self.subscriberViewBottom.frame
                let startPoint = CGPoint(x: startFrame.maxX, y: startFrame.midY)
                let endPoint = CGPoint(x: endFrame.minX, y: endFrame.midY)
                let path = UIBezierPath()
                path.move(to: self.eventBusView.center)
                path.addLine(to: startPoint)
                path.addCurve(
                    to: startPoint.applying(.init(translationX: 10.0, y: 10.0)),
                    controlPoint1: startPoint.applying(.init(translationX: 5.0, y: 0.0)),
                    controlPoint2: startPoint.applying(.init(translationX: 10.0, y: 5.0))
                )
                path.addLine(to: startPoint.applying(.init(translationX: 10.0, y: 50.0)))
                path.addCurve(
                    to: endPoint,
                    controlPoint1: endPoint.applying(.init(translationX: -10.0, y: -5.0)),
                    controlPoint2: endPoint.applying(.init(translationX: -5.0, y: 0.0))
                )
                path.addLine(to: self.subscriberViewBottom.center)
                return path
            }())
        }
    }

    func emitSignal(color: UIColor, onPath animationPath: UIBezierPath) {
        let signalLayer = CALayer()
        signalLayer.backgroundColor = color.cgColor
        signalLayer.bounds = CGRect(origin: CGPoint(), size: CGSize(width: 10.0, height: 10.0))
        signalLayer.cornerRadius = 5.0
        signalLayer.position = self.publisherView.center
        signalLayer.opacity = 0.0

        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.path = animationPath.cgPath

        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 1.0, 1.0, 0.0]

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
            positionAnimation,
            opacityAnimation
        ]
        animationGroup.repeatCount = 1
        animationGroup.duration = 1.0
        animationGroup.delegate = AnimationDelegate(layer: signalLayer)

        signalLayer.add(animationGroup, forKey: nil)
        self.containerView.layer.addSublayer(signalLayer)
    }
}

class AnimationDelegate: NSObject {

    let layer: CALayer

    init(layer: CALayer) {
        self.layer = layer
    }
}

extension AnimationDelegate: CAAnimationDelegate {
    func animationDidStart(_ animation: CAAnimation) {
        // Do nothing
    }

    func animationDidStop(_ animation: CAAnimation, finished: Bool) {
        self.layer.removeFromSuperlayer()
    }
}
