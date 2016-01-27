//
//  SAGOLBoard.swift
//  GameOfLife
//
//  Created by Frank Saar on 26/01/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import Foundation


public enum SAGOLNeighbourPosition : Int {
    case TopLeft
    case TopMiddle
    case TopRight
    case Left
    case Right
    case BottomLeft
    case BottomMiddle
    case BottomRight
}


public enum SAGOLBoardState : Int {
    case Alive = 1
    case Dead = 0
}

public struct SAGOLBoardGenerator : GeneratorType {
    private let max : (Column:Int,Row:Int,State: SAGOLBoardState)
    private let board : SAGOLBoard
    private var current : (Column:Int,Row:Int,State: SAGOLBoardState) = (0,0,SAGOLBoardState.Dead)
    init(board : SAGOLBoard,columns : Int, rows : Int) {
        self.max = (columns,rows,.Dead)
        self.current = (0,0,.Dead)
        self.board = board
    }
    public mutating func next() -> (Int,Int,SAGOLBoardState)? {
        if current.Row == self.max.Row {
            return nil
        }
        let state = self.board[current.Column,current.Row] ?? .Dead
        let old = (current.Column,current.Row,state)
        current.Column = current.Column.successor() % self.max.Column
        if current.Column == 0 {
            current.Row = current.Row.successor()
        }
        return old
    }
    
}


public struct SAGOLBoard : CustomStringConvertible {
    public let rows : Int
    public let columns : Int
    private var board : [[SAGOLBoardState]] = []
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
                let state = (self[column,row] ?? .Dead ).rawValue
                rowDesc += "\(state)"+" "
            }
            desc += (rowDesc + "\n")
        }
        return desc
        
    }
    
    public subscript(column : Int,row : Int) -> SAGOLBoardState? {
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
    
    private mutating func clearBoard() {
        let row = (0..<self.columns).map{ _ in SAGOLBoardState.Dead }
        let rows = (0..<self.rows).map{ _ in row }
        board = rows
    }
    
    public func populateBoard() -> SAGOLBoard {
        var newBoard = SAGOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,_) in self {
            newBoard[col,row] = arc4random() % 2 == 0 ? .Dead : .Alive
        }
        return newBoard
    }
    
    
    public func processBoard() -> SAGOLBoard {
        //1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        //2. Any live cell with two or three live neighbours lives on to the next generation.
        //3. Any live cell with more than three live neighbours dies, as if by over-population.
        //4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        
        var newBoard = SAGOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,state) in self {
            let livingNeighbours = self.livingNeighbours(col, row: row)
            if state == .Alive {
                switch livingNeighbours {
                case 0..<2: newBoard[col,row] = .Dead
                    
                case 2..<4: newBoard[col,row] = .Alive
                    
                case 4...8 : newBoard[col,row] = .Dead
                default: break
                }
                
            }
            else if livingNeighbours == 3
            {
                newBoard[col,row] = .Alive
            }
        }
        return newBoard
    }

}

// MARK: SequenceType

extension SAGOLBoard : SequenceType {
    public func generate() -> SAGOLBoardGenerator {
        return SAGOLBoardGenerator(board: self,columns: self.columns,rows: self.rows)
    }
}

// MARK: Equatable

extension SAGOLBoard : Equatable { }

public func ==(lhs : SAGOLBoard,rhs : SAGOLBoard ) -> Bool {
    let sameSize = (lhs.columns == rhs.columns) && (lhs.rows == rhs.rows)
    var sameContent = true
    if sameSize {
        for (column,row,lhsState) in lhs where sameContent == true {
            let rhsState = rhs[row,column] ?? .Dead
            sameContent = lhsState == rhsState ? sameContent : false
        }
    }
    let equal = sameSize && sameContent
    return equal
}

// Mark: Helper
extension SAGOLBoard {
    private func livingNeighbours(column : Int, row : Int) -> Int {
        var neighbours = 0
        
        for i in 0..<8 {
            switch (SAGOLNeighbourPosition(rawValue: i),column,row) {
            case (.Some(.TopLeft), 1..<self.columns, 1..<self.rows):
                neighbours = self.board[row-1][column-1] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.TopMiddle), 0..<self.columns , 1..<self.rows):
                neighbours = self.board[row-1][column] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.TopRight), 0..<self.columns-1 , 1..<self.rows):
                neighbours = self.board[row-1][column+1] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.Left), 1..<self.columns , _):
                neighbours = self.board[row][column-1] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.Right), 0..<self.columns-1 , _):
                neighbours = self.board[row][column+1] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.BottomLeft), 1..<self.columns , 0..<self.rows-1):
                neighbours = self.board[row+1][column-1] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.BottomMiddle), 0..<self.columns , 0..<self.rows-1):
                neighbours = self.board[row+1][column] == .Alive ? neighbours+1 : neighbours
                
            case (.Some(.BottomRight), 0..<self.columns-1 , 0..<self.rows-1):
                neighbours = self.board[row+1][column+1] == .Alive ? neighbours+1 : neighbours
                
            default:
                break
            }
        }
        return neighbours;
    }

}


