//
//  SATimer.swift
//  QUVoila
//
//  Created by Frank Saar on 12/11/2014.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit;

let GOLTimerHandlerDefaultTimerTolerance: Float=1.0;

public typealias GOLTimerHandler = (timer : GOLTimer)->();

@objc final public class GOLTimer: NSObject {
    private let timerInterval : NSTimeInterval;
    var currentTimerInterval : NSTimeInterval {
        return self.timerInterval;
    }
    private let timerHandler  : GOLTimerHandler?;
    private var timer : NSTimer? = nil;
    public var hasStarted : Bool  {
        let enabled=self.timer == nil ? false : true;
        return (enabled);
    }
    
    public init?(timerInterVal: NSTimeInterval,timerHandler:GOLTimerHandler) {
        self.timerInterval=NSTimeInterval(timerInterVal);
        self.timerHandler=timerHandler;
        super.init();
        let isZeroOrNegative =  self.timerInterval <= NSTimeInterval(0);
        if (isZeroOrNegative)
        {
            return (nil);
        }
    }
        
    public func start()
    {
        stop();
        self.timer=NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(GOLTimer.timerHandler(_:)), userInfo: nil, repeats: true);
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
