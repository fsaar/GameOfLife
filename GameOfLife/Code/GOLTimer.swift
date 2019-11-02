//
//  GOLTimer.swift
//
//  Created by Frank Saar on 12/11/2014.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit

typealias GOLTimerHandler = (_ timer : GOLTimer)->()

final class GOLTimer: NSObject {
    fileprivate let timerInterval : TimeInterval
    fileprivate let timerHandler  : GOLTimerHandler?
    fileprivate var timer : Timer? = nil
    var hasStarted : Bool  {
        let enabled=self.timer == nil ? false : true
        return (enabled)
    }
    
    init?(timerInterVal: TimeInterval,timerHandler:@escaping GOLTimerHandler) {
        self.timerInterval = TimeInterval(timerInterVal)
        self.timerHandler = timerHandler
        super.init()
        let isZeroOrNegative =  self.timerInterval <= TimeInterval(0)
        if isZeroOrNegative
        {
            return nil
        }
    }
        
    func start()
    {
        stop()
        self.timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.timerHandler?(self)
        }
    }
    
    deinit
    {
        stop()
    }
    
    func stop()
    {
        self.timer?.invalidate()
        self.timer = nil
    }
}
