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
    fileprivate var iterations : Int = 0
    static let gridElemetSize = CGSize(width: 40.0,height: 40.0)
    fileprivate lazy var timer : GOLTimer? = {
        let timer = GOLTimer(timerInterVal: GOLBoardViewController.timerInterval) { [weak self] timer in
            guard let newBoard = self?.board.processBoard() else {
                return
            }
            if let oldBoard = self?.board, newBoard != oldBoard {
                self?.iterations += 1
                self?.board = newBoard
            }
            else
            {
                timer.stop()
                self?.showDialog()
            }
        }
        return timer
    }()
    
    static let animationInterval : TimeInterval = 1.0
    static let timerInterval = animationInterval*1.2
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
        self.golView.animationInterval = GOLBoardViewController.animationInterval
        initBoard()
        timer?.start()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

// MARK: Helper
extension GOLBoardViewController {
    
    fileprivate func initBoard() {
        iterations = 0
        board = GOLBoard(rows: Int(boardSize.height), columns: Int(boardSize.width))
        board = board.populateBoard()
    }
    
    fileprivate func showDialog() {
        let sheet = UIAlertController(title: "Game Over after \(iterations) rounds", message: "Press 'Restart' to restart", preferredStyle: .alert)
        let restartAction = UIAlertAction.init(title: "Restart", style: .default) { [weak self] _ in
            self?.initBoard()
            self?.timer?.start()
        }
        sheet.addAction(restartAction)
        self.present(sheet, animated: true, completion: nil)

    }
    
    
}
