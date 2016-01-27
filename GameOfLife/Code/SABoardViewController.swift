//
//  SABoardViewController.swift
//  GameOfLife
//
//  Created by Frank Saar on 26/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit

private let SABoardViewControllerGridElemetSize = CGSize(width: 40.0,height: 40.0)

extension CGPoint : Hashable {
    public var hashValue: Int {
        return (self.x * SABoardViewControllerGridElemetSize.height+self.y).hashValue
    }

}

@objc class SABoardViewController: UIViewController {
    var timer : SATimer?
    var board : SAGOLBoard = SAGOLBoard(rows: 0, columns: 0) {
        willSet(newBoard) {
            if (board.columns == newBoard.columns && board.rows == newBoard.rows) {
                self.transitionBoard(from: board, to: newBoard)
            }
        }
    }
    var imageViewList : [CGPoint : UIImageView] = [:]
    var boardSize : CGSize {
        let viewSize = self.view.frame.size
        let size = CGSize(width: Int(viewSize.width/SABoardViewControllerGridElemetSize.width),
            height: Int(viewSize.height/SABoardViewControllerGridElemetSize.width))
        return size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBoard()
        showBoard()
        
        self.timer = SATimer(timerInterVal: 1.2, timerHandler: { [weak self] _ in
            let newBoard = self?.board.processBoard()
            if let newBoard = newBoard  {
                self?.board = newBoard
            }
        })
        self.timer?.start()
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

// MARK: Helper
extension SABoardViewController {
    
    private func transitionBoard(from from: SAGOLBoard, to: SAGOLBoard) {
        for (col,row,oldState) in from {
            let newState = to[col,row]
            if let newState = newState where newState != oldState,
                let imageView = self.imageViewList[CGPoint(x: col, y: row)] {
                    setImageViewState(imageView, state: newState,animated: true)
            }
        }

    }
    
    private func initBoard() {
        board = SAGOLBoard(rows: Int(boardSize.height), columns: Int(boardSize.width))
        board = board.populateBoard()
        
    }
    
    private func topLeftPointForPos(column : Int, row : Int) -> CGPoint {
        guard column >= 0 && row >= 0 else {
            return CGPointZero
        }
        return CGPoint(x: Int(SABoardViewControllerGridElemetSize.width) * column, y: Int(SABoardViewControllerGridElemetSize.height) * row)
    }
    
    private func imageViewForPosition(column colum : Int, row: Int) ->UIImageView {
        let image = UIImage(named: "Orb")?.imageWithRenderingMode(.AlwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: topLeftPointForPos(colum, row: row), size: SABoardViewControllerGridElemetSize)
        imageView.hidden = true
        imageView.alpha = 0.9
        return imageView
        
    }
    
    private func setImageViewState(imageView: UIImageView, state : SAGOLBoardState, animated : Bool = false) {
        let transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01)
        let isAlive = state == .Alive
        if animated
        {
            imageView.hidden = isAlive ? false : imageView.hidden
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                imageView.transform = isAlive ? CGAffineTransformIdentity : transform
                imageView.tintColor = isAlive ? UIColor .greenColor() : UIColor.grayColor()
            }, completion: { _ in
                imageView.hidden = isAlive ? imageView.hidden : true
            })
        }
        else
        {
            imageView.tintColor = isAlive ? UIColor .greenColor() : UIColor.grayColor()
            imageView.hidden = isAlive ? false : true
            imageView.transform = isAlive ? CGAffineTransformIdentity : transform
        }
        
    }
    
    private func showBoard(animated : Bool = false) {
        for (col,row,state) in board {
            let imageView = imageViewForPosition(column: col, row: row)
            self.imageViewList[CGPoint(x: col, y: row)] = imageView
            self.view .addSubview(imageView)
            imageView.hidden = state == .Alive ? false : true
            setImageViewState(imageView, state: state)
        }
        
    }
    
}