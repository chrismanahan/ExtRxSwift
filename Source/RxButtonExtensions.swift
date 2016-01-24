//
//  RxButtonExtensions.swift
//  EmojiSearch
//
//  Created by Chris M on 1/23/16.
//  Copyright © 2016 Chris Manahan. All rights reserved.
//

import RxCocoa
import RxSwift

extension UIButton {
    public func rx_hold(interval: Double = 0.2) -> ControlEvent<Void> {
        let source: Observable<Void> = Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            guard self != nil else {
                observer.on(.Completed)
                return NopDisposable.instance
            }
            
            var isHeld = false
            
            let down = self!.rx_controlEvent(.TouchDown)
                .subscribeNext { isHeld = true }
            
            let upInside = self!.rx_controlEvent(.TouchUpInside)
                .subscribeNext { isHeld = false }
            
            let upOutside = self!.rx_controlEvent(.TouchUpOutside)
                .subscribeNext { isHeld = false }
            
            let target = HoldTarget(button: self!, interval: interval) { button in
                if isHeld {
                    observer.on(.Next())
                }
            }
            
            return AnonymousDisposable {
                target.dispose()
                down.dispose()
                upInside.dispose()
                upOutside.dispose()
            }
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(events: source)
    }
}

class HoldTarget: Disposable {
    typealias Callback = (UIButton) -> Void
    
    let selector: Selector = "timerHandler"
    
    weak var button: UIButton?
    var callback: Callback?
    var timer: NSTimer?
    
    init(button: UIButton, interval: Double = 0.2, callback: Callback) {
        self.button = button
        self.callback = callback
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: selector, userInfo: nil, repeats: true)
    }
    
    @objc func timerHandler() {
        if let callback = self.callback, button = self.button {
            callback(button)
        }
    }
    
    func dispose() {
        self.timer?.invalidate()
        self.timer = nil
        self.callback = nil
    }
}
