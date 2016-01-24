//
//  GlobalFunctions.swift
//  ExtRxSwift
//
//  Created by Chris M on 11/30/15.
//  Copyright © 2015 Christopher Manahan. All rights reserved.
//

import RxSwift

func combineSignals<T>(signals: [Observable<T>], combine: (T,T)->T ) -> Observable<T> {
    assert (signals.count >= 1)
    guard signals.count >= 2 else { return signals[0] }
    
    var comb = combineLatest(signals[0], signals[1]) { combine($0) }
    for i in 2..<signals.count {
        comb = combineLatest(comb, signals[i]) { combine($0) }
    }
    return comb
}