//
//  GOLView.swift
//  GameOfLife
//
//  Created by Frank Saar on 24/09/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit

extension CGPoint : Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class GOLView: UIView {
    var animationInterval : TimeInterval = 1

    var board : GOLBoard? = nil {
        willSet(newBoard) {
            if let board = board, let  newBoard = newBoard , board.size == newBoard.size {
                self.transitionBoard(from: board, to: newBoard)
            }
        }
        didSet(oldValue) {
            if case .none = oldValue,let _ = board {
                showBoard()
            }
        }
    }
    fileprivate var imageViewList : [CGPoint : GOLImageView] = [:]
}

//
// MARK: - Helper
//
extension GOLView {
    func transitionBoard(from: GOLBoard, to: GOLBoard) {
        for (col,row,oldState) in from {
            let newState = to[col,row]
            if let newState = newState , newState != oldState,
                let imageView = self.imageViewList[CGPoint(x: col, y: row)]  {
                imageView.setImageViewState(newState,animated: true,withAnimationInterval: self.animationInterval)
            }
        }
    }
    
    func showBoard(_ animated : Bool = false) {
        guard let board = board else {
            return
        }
        
        for (col,row,state) in board {
            let  origin = CGPoint(x: Int(GOLBoardViewController.gridElemetSize.width) * col, y: Int(GOLBoardViewController.gridElemetSize.height) * row)
            let frame = CGRect(origin: origin, size: GOLBoardViewController.gridElemetSize)
            let imageView = GOLImageView(frame: frame)
            self.imageViewList[CGPoint(x: col, y: row)] = imageView
            self.addSubview(imageView)
            imageView.setImageViewState(state,animated: false)
        }
        
    }
}
