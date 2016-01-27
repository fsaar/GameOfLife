//
//  SAGOLImageView.swift
//  GameOfLife
//
//  Created by Frank Saar on 27/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit


@objc public class SAGOLImageView : UIImageView {
    public private(set) var state : SAGOLBoardState  = .Dead
    
     init(frame: CGRect, state : SAGOLBoardState) {
        super.init(frame: frame)
        self.image = UIImage(named: "Orb")?.imageWithRenderingMode(.AlwaysTemplate)
        self.alpha = 0.9
        self.state = state
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01)
        self.tintColor   = UIColor.grayColor()
        self.hidden = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public func setImageViewState(state : SAGOLBoardState, animated : Bool = false) {
        let transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01)
        let isAlive = state == .Alive
        if animated
        {
            self.hidden = isAlive ? false : self.hidden
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.transform = isAlive ? CGAffineTransformIdentity : transform
                self.tintColor = isAlive ? UIColor .greenColor() : UIColor.grayColor()
                }, completion: { _ in
                    self.hidden = isAlive ? self.hidden : true
            })
        }
        else
        {
            self.tintColor = isAlive ? UIColor .greenColor() : UIColor.grayColor()
            self.hidden = isAlive ? false : true
            self.transform = isAlive ? CGAffineTransformIdentity : transform
        }
        
    }
    
}


