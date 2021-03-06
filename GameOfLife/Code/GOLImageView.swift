//
//  GameOfLife
//
//  Created by Frank Saar on 27/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit


class GOLImageView : UIImageView {
    open fileprivate(set) var state : GOLBoardState  = .dead
    let defaultTransform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
    fileprivate static let animationInterval : TimeInterval = 1
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.image = UIImage(named: "Orb")?.withRenderingMode(.alwaysTemplate)
        self.alpha = 0.9
        self.state = .dead
        self.transform = self.defaultTransform
        self.tintColor   = UIColor.gray
        self.isHidden = true
    }

    @available(*, unavailable) required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setImageViewState(_ state : GOLBoardState,
                                    animated : Bool = false,
                                    withAnimationInterval animationInterval : TimeInterval = GOLImageView.animationInterval) {
        let isAlive = state == .alive
        if animated
        {
            self.isHidden = isAlive ? false : self.isHidden
            UIView.animate(withDuration: animationInterval, animations: {
                self.transform = isAlive ? .identity : self.defaultTransform
                self.tintColor = isAlive ? .green : .gray
                }, completion: { _ in
                    self.isHidden = isAlive ? self.isHidden : true
            })
        }
        else
        {
            self.tintColor = isAlive ? .green : .gray
            self.isHidden = isAlive ? false : true
            self.transform = isAlive ? .identity : self.defaultTransform
        }
        
    }
    
}
