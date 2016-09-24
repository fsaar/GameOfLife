//
//  GOLBoard.swift
//  GameOfLife
//
//  Created by Frank Saar on 26/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import Foundation


public enum GOLNeighbourPosition : Int {
    case topLeft
    case topMiddle
    case topRight
    case left
    case right
    case bottomLeft
    case bottomMiddle
    case bottomRight
}


public enum GOLBoardState : Int {
    case alive = 1
    case dead = 0
}

public struct GOLBoardGenerator : IteratorProtocol {
    fileprivate let max : (Column:Int,Row:Int,State: GOLBoardState)
    fileprivate let board : GOLBoard
    fileprivate var current : (Column:Int,Row:Int,State: GOLBoardState) = (0,0,GOLBoardState.dead)
    init(board : GOLBoard,columns : Int, rows : Int) {
        self.max = (columns,rows,.dead)
        self.current = (0,0,.dead)
        self.board = board
    }
    public mutating func next() -> (Int,Int,GOLBoardState)? {
        if current.Row == self.max.Row {
            return nil
        }
        let state = self.board[current.Column,current.Row] ?? .dead
        let old = (current.Column,current.Row,state)
        current.Column = (current.Column + 1) % self.max.Column
        if current.Column == 0 {
            current.Row = (current.Row + 1)
        }
        return old
    }
    
}


public struct GOLBoard : CustomStringConvertible,Equatable {
    static let zero = GOLBoard(rows:0, columns:0)
    public let rows : Int
    public let columns : Int
    fileprivate var board : [[GOLBoardState]] = []
    init(rows: Int,columns : Int) {
        self.rows = rows
        self.columns = columns
        clearBoard()
    }
    
    public var description: String {
        var desc = ""
        for row in 0..<self.rows {
            var rowDesc = ""
            for column in 0..<self.columns {
                let state = (self[column,row] ?? .dead ).rawValue
                rowDesc += "\(state)"+" "
            }
            desc += (rowDesc + "\n")
        }
        return desc
        
    }
    
    public subscript(column : Int,row : Int) -> GOLBoardState? {
        get {
            guard ((column < self.columns) && (row < self.rows)) else {
                return nil
            }
            return self.board[row][column]
        }
        set {
            if ((column < self.columns) && (row < self.rows)),let newValue = newValue {
                board[row][column] = newValue
            }
            
        }
    }
    
    fileprivate mutating func clearBoard() {
        let row = (0..<self.columns).map{ _ in GOLBoardState.dead }
        let rows = (0..<self.rows).map{ _ in row }
        board = rows
    }
    
    public func populateBoard() -> GOLBoard {
        var newBoard = GOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,_) in self {
            newBoard[col,row] = arc4random() % 2 == 0 ? .dead : .alive
        }
        return newBoard
    }
    
    public static func ==(lhs : GOLBoard,rhs : GOLBoard ) -> Bool {
        let sameSize = (lhs.columns == rhs.columns) && (lhs.rows == rhs.rows)
        var sameContent = true
        if sameSize {
            for (column,row,lhsState) in lhs where sameContent == true {
                let rhsState = rhs[row,column] ?? .dead
                sameContent = lhsState == rhsState ? sameContent : false
            }
        }
        let equal = sameSize && sameContent
        return equal
    }
    

    public func processBoard() -> GOLBoard {
        //1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        //2. Any live cell with two or three live neighbours lives on to the next generation.
        //3. Any live cell with more than three live neighbours dies, as if by over-population.
        //4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        
        var newBoard = GOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,state) in self {
            let livingNeighbours = self.livingNeighbours(col, row: row)
            if state == .alive {
                switch livingNeighbours {
                case 0..<2: newBoard[col,row] = .dead
                    
                case 2..<4: newBoard[col,row] = .alive
                    
                case 4...8 : newBoard[col,row] = .dead
                default: break
                }
                
            }
            else if livingNeighbours == 3
            {
                newBoard[col,row] = .alive
            }
        }
        return newBoard
    }

}

// MARK: SequenceType

extension GOLBoard : Sequence {
    public func makeIterator() -> GOLBoardGenerator {
        return GOLBoardGenerator(board: self,columns: self.columns,rows: self.rows)
    }
}


// Mark: Helper
extension GOLBoard {
    fileprivate func livingNeighbours(_ column : Int, row : Int) -> Int {
        var neighbours = 0
        let positions = (0..<8).flatMap { GOLNeighbourPosition(rawValue : $0) }
        for pos in positions {
            switch (pos,column,row) {
            case (.topLeft, 1..<self.columns, 1..<self.rows):
                neighbours = self.board[row-1][column-1] == .alive ? neighbours+1 : neighbours
                
            case (.topMiddle, 0..<self.columns , 1..<self.rows):
                neighbours = self.board[row-1][column] == .alive ? neighbours+1 : neighbours
                
            case (.topRight, 0..<self.columns-1 , 1..<self.rows):
                neighbours = self.board[row-1][column+1] == .alive ? neighbours+1 : neighbours
                
            case (.left, 1..<self.columns , _):
                neighbours = self.board[row][column-1] == .alive ? neighbours+1 : neighbours
                
            case (.right, 0..<self.columns-1 , _):
                neighbours = self.board[row][column+1] == .alive ? neighbours+1 : neighbours
                
            case (.bottomLeft, 1..<self.columns , 0..<self.rows-1):
                neighbours = self.board[row+1][column-1] == .alive ? neighbours+1 : neighbours
                
            case (.bottomMiddle, 0..<self.columns , 0..<self.rows-1):
                neighbours = self.board[row+1][column] == .alive ? neighbours+1 : neighbours
                
            case (.bottomRight, 0..<self.columns-1 , 0..<self.rows-1):
                neighbours = self.board[row+1][column+1] == .alive ? neighbours+1 : neighbours
                
            default:
                break
            }
        }
        return neighbours;
    }

}


