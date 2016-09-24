//
//  GOLTimer.swift
//
//  Created by Frank Saar on 12/11/2014.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit

let GOLTimerHandlerDefaultTimerTolerance: Float=1.0

public typealias GOLTimerHandler = (_ timer : GOLTimer)->()

@objc final public class GOLTimer: NSObject {
    fileprivate let timerInterval : TimeInterval
    var currentTimerInterval : TimeInterval {
        return self.timerInterval
    }
    fileprivate let timerHandler  : GOLTimerHandler?
    fileprivate var timer : Timer? = nil
    public var hasStarted : Bool  {
        let enabled=self.timer == nil ? false : true
        return (enabled)
    }
    
    public init?(timerInterVal: TimeInterval,timerHandler:@escaping GOLTimerHandler) {
        self.timerInterval=TimeInterval(timerInterVal)
        self.timerHandler=timerHandler
        super.init()
        let isZeroOrNegative =  self.timerInterval <= TimeInterval(0)
        if (isZeroOrNegative)
        {
            return (nil)
        }
    }
        
    public func start()
    {
        stop()
        self.timer=Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(GOLTimer.timerHandler(_:)), userInfo: nil, repeats: true)
    }
    
    deinit
    {
        stop()
    }
    
    public func stop()
    {
        self.timer?.invalidate()
        self.timer=nil
    }
 
    func timerHandler(_ timer: Timer)
    {
        timerHandler?(self)
    }
}
