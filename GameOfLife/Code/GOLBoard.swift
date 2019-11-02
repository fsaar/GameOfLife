//
//  GOLBoard.swift
//  GameOfLife
//
//  Created by Frank Saar on 26/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import Foundation
import CoreGraphics




enum GOLBoardState : Int {
    case alive = 1
    case dead = 0
        
    func nextState(with livingNeighbours : Int) -> GOLBoardState {
        //1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        //2. Any live cell with two or three live neighbours lives on to the next generation.
        //3. Any live cell with more than three live neighbours dies, as if by over-population.
        //4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        switch self {
        case .alive:
            switch livingNeighbours {
            case 2...3:
                return .alive
            default:
                return .dead
            }
        case .dead :
            return livingNeighbours == 3 ? .alive : .dead
        }
    }
}

struct GOLBoardGenerator : IteratorProtocol {
    fileprivate let max : (column:Int,row:Int,state: GOLBoardState)
    fileprivate let board : GOLBoard
    fileprivate var current : (column:Int,row:Int,state: GOLBoardState) = (0,0,GOLBoardState.dead)
    
    init(board : GOLBoard,columns : Int, rows : Int) {
        self.max = (columns,rows,.dead)
        self.current = (0,0,.dead)
        self.board = board
    }
    mutating func next() -> (Int,Int,GOLBoardState)? {
        if current.row == self.max.row {
            return nil
        }
        let state = self.board[current.column,current.row] ?? .dead
        let old = (current.column,current.row,state)
        current.column = (current.column + 1) % self.max.column
        if current.column == 0 {
            current.row += 1
        }
        return old
    }
    
}


struct GOLBoard : CustomStringConvertible,Equatable {
    fileprivate enum GOLNeighbourPosition : Int,CaseIterable {
        case topLeft
        case topMiddle
        case topRight
        case left
        case right
        case bottomLeft
        case bottomMiddle
        case bottomRight
        
        var offsets : (x : Int,y : Int) {
            switch self {
            case .topLeft:
                return (-1,-1)
            case .topMiddle:
                return (0,-1)
            case .topRight:
                return (1,-1)
            case .left:
                return (-1,0)
            case .right:
                return (1,1)
            case .bottomLeft:
                return (-1,1)
            case .bottomMiddle:
                return (0,1)
            case .bottomRight:
                return (1,1)
            }
        }
    }
    
    static let empty = GOLBoard(rows:0, columns:0)
    var size : CGSize {
        return CGSize(width:self.columns,height:self.rows)
    }
    let rows : Int
    let columns : Int
    fileprivate var board : [[GOLBoardState]] = []
    
    init(rows: Int,columns : Int) {
        self.rows = rows
        self.columns = columns
        clearBoard()
    }
    
    var description: String {
        var desc = ""
        for (col,_,state) in self {
            desc += col == self.columns-1 ? "\(state.rawValue)\n" :  "\(state.rawValue)"
        }
        return desc
        
    }
    
    subscript(column : Int,row : Int) -> GOLBoardState? {
        get {
            guard (column < self.columns) && (row < self.rows) else {
                return nil
            }
            return self.board[row][column]
        }
        set {
            if (column < self.columns) && (row < self.rows),let newValue = newValue {
                board[row][column] = newValue
            }
            
        }
    }
    
    func populateBoard() -> GOLBoard {
        var newBoard = GOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,_) in self {
            newBoard[col,row] = Int.random(in: 0...1) == 0 ? .dead : .alive
        }
        return newBoard
    }
    
    static func ==(lhs : GOLBoard,rhs : GOLBoard ) -> Bool {
        let lhsString = lhs.map { _,_,state in "\(state.rawValue)" }.joined(separator: "")
        let rhsString = rhs.map { _,_,state in "\(state.rawValue)" }.joined(separator: "")
        return lhsString == rhsString
    }
    

    func processBoard() -> GOLBoard {
        var newBoard = GOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,state) in self {
            let livingNeighbours = self.livingNeighbours(col, row: row)
            newBoard[col,row] = state.nextState(with: livingNeighbours)
        }
        return newBoard
    }

}

//
// MARK: - SequenceType
//
extension GOLBoard : Sequence {
    func makeIterator() -> GOLBoardGenerator {
        return GOLBoardGenerator(board: self,columns: self.columns,rows: self.rows)
    }
}

//
// MARK: - Helper
//
fileprivate extension GOLBoard {
    mutating func clearBoard() {
        let row = (0..<self.columns).map{ _ in GOLBoardState.dead }
        let rows = (0..<self.rows).map{ _ in row }
        board = rows
    }
    
    func livingNeighbours(_ column : Int, row : Int) -> Int {
        let neighbours = GOLNeighbourPosition.allCases.reduce(0) { sum,pos in
            let offset = pos.offsets
            let (x,y) = (column + offset.x, row + offset.y)
            guard 0..<columns ~= x, 0..<rows ~= y else {
                return sum
            }
            let positionIsAlive = board[y][x]  == .alive
            return positionIsAlive ? sum + 1 : sum
        }
        return neighbours
    }
}
