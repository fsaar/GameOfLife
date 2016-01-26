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


public struct SAGOLBoard : CustomStringConvertible{
    let rows : Int
    let columns : Int
    public var board : [[SAGOLBoardState]] = []
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
                rowDesc += "\((board[row][column]).rawValue)"+" "
            }
            desc += (rowDesc + "\n")
        }
        return desc
        
    }
    
    subscript(column : Int,row : Int) -> SAGOLBoardState? {
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
        for row in 0..<self.rows {
            for column in 0..<self.columns {
                newBoard[column,row] = arc4random() % 2 == 0 ? .Dead : .Alive
            }
        }
        return newBoard
    }
    
    public func livingNeighbours(column : Int, row : Int) -> Int {
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
    
    public func processBoard() -> SAGOLBoard {
        //1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        //2. Any live cell with two or three live neighbours lives on to the next generation.
        //3. Any live cell with more than three live neighbours dies, as if by over-population.
        //4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        
        var newBoard = SAGOLBoard(rows: self.rows, columns: self.columns)
        for col in 0..<columns {
            for row in 0..<rows {
                let livingNeighbours = self.livingNeighbours(col, row: row)
                if self[col,row] == .Alive {
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
        }
        return newBoard
    }

}

// MARK: Equatable

extension SAGOLBoard : Equatable { }

public func ==(lhs : SAGOLBoard,rhs : SAGOLBoard ) -> Bool {
    let sameSize = (lhs.columns == rhs.columns) && (lhs.rows == rhs.rows)
    var sameContent = true
    if sameSize {
        for row in 0...lhs.rows {
            for column in 0...rhs.columns {
                sameContent = lhs[row,column] == rhs[row,column] ? sameContent : false
            }
        }
    }
    let equal = sameSize && sameContent
    return equal
}


