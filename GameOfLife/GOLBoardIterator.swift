
import Foundation

private struct Position {
    var column: Int
    var row: Int
    let max : (columns:Int,rows:Int)
    var isFinal : Bool
    init(columns: Int, rows: Int) {
        self.column = 0
        self.row = 0
        self.max = (columns,rows)
        self.isFinal = self.row >= self.max.rows
    }
    public static func += ( lhs: inout Self,rhs: Int)  {
        guard !lhs.isFinal else {
            return
        }
        lhs.column = (lhs.column + 1) % lhs.max.columns
        if lhs.column == 0 {
            lhs.row = min(lhs.max.rows ,lhs.row + 1)
        }
        lhs.isFinal = lhs.row >= lhs.max.rows
    }
}

struct GOLBoardIterator : IteratorProtocol {
    private let board : GOLBoard
    private var nextPos : Position
    
    init(board : GOLBoard) {
        self.nextPos = Position(columns: board.columns,rows: board.rows)
        self.board = board
    }
    
    mutating func next() -> (column:Int,row:Int,state:GOLBoardState)? {
        guard !nextPos.isFinal,let state = self.board[nextPos.column,nextPos.row] else {
            return nil
        }
        defer {
            nextPos += 1
        }
        return (nextPos.column,nextPos.row,state)
    }
    
}
