//
//  SATimer.swift
//  QUVoila
//
//  Created by Frank Saar on 12/11/2014.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit;

let SATimerHandlerDefaultTimerTolerance: Float=1.0;

public typealias SATimerHandler = (timer : SATimer)->();

@objc final public class SATimer: NSObject {
    private let timerInterval : NSTimeInterval;
    var currentTimerInterval : NSTimeInterval {
        return self.timerInterval;
    }
    private let timerHandler  : SATimerHandler?;
    private var timer : NSTimer? = nil;
    public var hasStarted : Bool  {
        let enabled=self.timer == nil ? false : true;
        return (enabled);
    }
    
    public init?(timerInterVal: NSTimeInterval,timerHandler:SATimerHandler?) {
        self.timerInterval=NSTimeInterval(timerInterVal);
        self.timerHandler=timerHandler;
        super.init();
        let isZeroOrNegative =  self.timerInterval <= NSTimeInterval(0);
        let hasNilHandler = timerHandler == nil;
        if (isZeroOrNegative || hasNilHandler)
        {
            return (nil);
        }
    }
        
    public func start()
    {
        stop();
        self.timer=NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: Selector("timerHandler:"), userInfo: nil, repeats: true);
    }
    
    deinit
    {
        stop();
    }
    
    public func stop()
    {
        self.timer?.invalidate();
        self.timer=nil;
    }
 
    func timerHandler(timer: NSTimer)
    {
        timerHandler?(timer: self);
    }
}
