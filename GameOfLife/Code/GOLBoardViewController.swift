//
//  SABoardViewController.swift
//  GameOfLife
//
//  Created by Frank Saar on 26/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit
import Combine

class GOLBoardViewController: UIViewController {
    fileprivate enum GOLError : Error {
        case gameOver
    }
    @IBOutlet weak var golView : GOLView! {
        didSet {
             self.golView.animationInterval = GOLBoardViewController.timerInterval
        }
    }
    fileprivate var iterations : Int = 0
    static let gridElemetSize = CGSize(width: 40.0,height: 40.0)
  
    static let animationInterval : TimeInterval = 0.5
    static let timerInterval = animationInterval*1.2

    fileprivate var boardSize : CGSize {
        let viewSize = self.view.frame.size
        let size = CGSize(width: Int(viewSize.width/GOLBoardViewController.gridElemetSize.width),
            height: Int(viewSize.height/GOLBoardViewController.gridElemetSize.width))
        return size
    }
    
    fileprivate var boardRenewalTimer : AnyCancellable?
    @Published fileprivate var golBoard : GOLBoard = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boardRenewalTimer = startTimer()
        _ = $golBoard.compactMap { $0 }.filter { !$0.isEmpty }.receive(on: RunLoop.main).sink { [weak self] board in
            self?.golView.board = board
            self?.iterations += 1
        }
        
        _ = $golBoard.compactMap { $0 }.filter { $0.isEmpty }.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.boardRenewalTimer?.cancel()
            self?.showDialog()
        }
    }
    
    func startTimer() -> AnyCancellable {
        let board =  GOLBoard(rows: Int(boardSize.height), columns: Int(boardSize.width)).populateBoard()
        return Timer.publish(every: GOLBoardViewController.timerInterval, on:.main, in: .common).autoconnect().tryScan(board) { last,_ in
            let newBoard = last?.processBoard()
            guard newBoard != last else {
                throw GOLError.gameOver
            }
            return newBoard
        }.catch { _  in
            Just(GOLBoard.empty)
        }.assign(to: \.golBoard, on: self)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

//
// MARK: - Helper
//
fileprivate extension GOLBoardViewController {
    
    func showDialog() {
        let sheet = UIAlertController(title: "Game Over after \(iterations) rounds", message: "Press 'Restart' to restart", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.iterations = 0
            self?.golBoard = nil
            self?.boardRenewalTimer = self?.startTimer()
        }
        sheet.addAction(restartAction)
        self.present(sheet, animated: true, completion: nil)
    }
}
