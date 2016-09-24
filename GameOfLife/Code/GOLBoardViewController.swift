//
//  SABoardViewController.swift
//  GameOfLife
//
//  Created by Frank Saar on 26/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit

@objc class GOLBoardViewController: UIViewController {
    @IBOutlet weak var golView : GOLView!
    static let gridElemetSize = CGSize(width: 40.0,height: 40.0)
    fileprivate var timer : GOLTimer?
    fileprivate var board : GOLBoard = .empty {
        didSet {
            golView.board = board
        }
    }
    fileprivate var boardSize : CGSize {
        let viewSize = self.view.frame.size
        let size = CGSize(width: Int(viewSize.width/GOLBoardViewController.gridElemetSize.width),
            height: Int(viewSize.height/GOLBoardViewController.gridElemetSize.width))
        return size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBoard()
        
        self.timer = GOLTimer(timerInterVal: 1.2, timerHandler: { [weak self] _ in
            guard let newBoard = self?.board.processBoard() else {
                return
            }
            self?.board = newBoard
        })
        self.timer?.start()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

// MARK: Helper
extension GOLBoardViewController {
    
    fileprivate func initBoard() {
        board = GOLBoard(rows: Int(boardSize.height), columns: Int(boardSize.width))
        board = board.populateBoard()
    }
    
    
}
