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
    private var timer : SATimer?
    private var board : SAGOLBoard = SAGOLBoard(rows: 0, columns: 0) {
        willSet(newBoard) {
            if (board.columns == newBoard.columns && board.rows == newBoard.rows) {
                self.transitionBoard(from: board, to: newBoard)
            }
        }
    }
    private var imageViewList : [CGPoint : UIImageView] = [:]
    private var boardSize : CGSize {
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
                let imageView = self.imageViewList[CGPoint(x: col, y: row)] as? SAGOLImageView {
                    imageView.setImageViewState(newState,animated: true)
            }
        }
    }
    
    private func initBoard() {
        board = SAGOLBoard(rows: Int(boardSize.height), columns: Int(boardSize.width))
        board = board.populateBoard()
        
    }
    
    private func showBoard(animated : Bool = false) {
        for (col,row,state) in board {
            let  origin = CGPoint(x: Int(SABoardViewControllerGridElemetSize.width) * col, y: Int(SABoardViewControllerGridElemetSize.height) * row)
            let frame = CGRect(origin: origin, size: SABoardViewControllerGridElemetSize)
            let imageView = SAGOLImageView(frame: frame,state: state)
            self.imageViewList[CGPoint(x: col, y: row)] = imageView
            self.view .addSubview(imageView)
            imageView.hidden = state == .Alive ? false : true
        }
        
    }
    
}