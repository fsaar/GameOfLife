
import Foundation
import CoreGraphics

enum GOLBoardError : Error {
    case invalidParameter
}

struct GOLBoard : CustomStringConvertible,Equatable {
    private enum GOLNeighbourPosition : Int,CaseIterable {
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
    
   
    var size : CGSize {
        CGSize(width:self.columns,height:self.rows)
    }
    var rows : Int {
         board.count
    }
    var columns : Int {
         board.first?.count ?? 0
    }
    private var board : [[GOLBoardState]] = []
    
    init(rows: Int,columns : Int) throws {
        guard rows * columns > 0 else {
            throw GOLBoardError.invalidParameter
        }
        let values = (0..<rows * columns).map { _ in GOLBoardState.dead }
        self.board = (0..<rows).map { Array(values[$0 * columns..<($0+1)*columns]) }
    }
    
    init(columns : Int, rows: Int, values: [GOLBoardState]) throws {
        guard values.count == columns * rows, !values.isEmpty else {
            throw GOLBoardError.invalidParameter
        }
        self.board = (0..<rows).map { Array(values[$0 * columns..<($0+1)*columns]) }
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
    
    func populateBoard() throws -> GOLBoard {
        var newBoard = try GOLBoard(rows: self.rows, columns: self.columns)
        for (col,row,_) in self {
            newBoard[col,row] = Int.random(in: 0...1) == 0 ? .dead : .alive
        }
        return newBoard
    }
    
    static func ==(lhs : GOLBoard,rhs : GOLBoard ) -> Bool {
        guard lhs.size == rhs.size else {
            return false
        }
        let lhsString = lhs.map { _,_,state in "\(state.rawValue)" }.joined(separator: "")
        let rhsString = rhs.map { _,_,state in "\(state.rawValue)" }.joined(separator: "")
        return lhsString == rhsString
    }
    

    func process() throws -> GOLBoard {
        var newBoard = try GOLBoard(rows: self.rows, columns: self.columns)
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
    func makeIterator() -> GOLBoardIterator {
        GOLBoardIterator(board: self)
    }
}

//
// MARK: - Helper
//
fileprivate extension GOLBoard {
    
    func livingNeighbours(_ column : Int, row : Int) -> Int {
        let neighbours = GOLNeighbourPosition.allCases.reduce(0) { sum,pos in
            let offset = pos.offsets
            let (x,y) = (column + offset.x, row + offset.y)
            guard 0..<columns ~= x, 0..<rows ~= y else {
                return sum
            }
            let positionIsAlive = self[x,y]  == .alive
            return positionIsAlive ? sum + 1 : sum
        }
        return neighbours
    }
}
