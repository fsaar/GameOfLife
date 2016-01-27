//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

extension NSDate : Comparable {}

let numbers =  (1...100).filter { $0 % 2 == 0}.map{ $0 * 2}
print (numbers)

let date = NSDate()
let futureDate=NSDate(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate+NSTimeInterval(100000))
let dateFormatter = NSDateFormatter()
let s  = dateFormatter.stringFromDate(futureDate)
let timeInterval = futureDate.timeIntervalSinceDate(date)

func __filterVouchers(vouchers : [NSDate]) -> [NSDate] {
    let filtered_vouchers = vouchers.filter { $0 > NSDate() }
    return filtered_vouchers
}

__filterVouchers([futureDate])


let date1 = "2016-02-26"

//let board3 =  board.flatMap { $0 }

//1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
//2. Any live cell with two or three live neighbours lives on to the next generation.
//3. Any live cell with more than three live neighbours dies, as if by over-population.
//4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

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

print (SAGOLNeighbourPosition.RawValue.max)
print (SAGOLNeighbourPosition.RawValue.min)

public enum SAGOLBoardState : Int {
    case Alive = 1
    case Dead = 0
}

public struct BoardGenerator : GeneratorType {
    let max : (Column:Int,Row:Int)
    var current : (Column:Int,Row:Int) = (0,0)
    init(columns : Int, rows : Int) {
        self.max = (columns,rows)
        self.current = (0,0)
    }
    public mutating func next() -> (Int,Int)? {
        if current.Row == self.max.Row {
            return nil
        }
        let old = current
        current.Column = current.Column.successor() % self.max.Column
        if current.Column == 0 {
            current.Row = current.Row.successor()
        }
        return old
    }

}



public struct Board : CustomStringConvertible , SequenceType {
    let rows : Int
    let columns : Int
    public var board : [[SAGOLBoardState]] = []
    init(rows: Int,columns : Int) {
        self.rows = rows
        self.columns = columns
        clearBoard()
    }
    
    public func generate() -> BoardGenerator {
        return BoardGenerator(columns: self.columns, rows: self.rows)
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
    
    public func populateBoard() -> Board {
        var newBoard = Board(rows: self.rows, columns: self.columns)
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
    
    public func processBoard() ->Board {
        //1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        //2. Any live cell with two or three live neighbours lives on to the next generation.
        //3. Any live cell with more than three live neighbours dies, as if by over-population.
        //4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

        var newBoard = Board(rows: self.rows, columns: self.columns)
        for (col,row) in self {
            let livingNeighbours = self.livingNeighbours(col, row: row)
            if self[col,row] == .Alive {
                switch livingNeighbours {
                case 0..<2: newBoard[col,row] = .Dead
                    
                case 2...3: newBoard[col,row] = .Alive
                
                case _ where livingNeighbours > 3 : newBoard[col,row] = .Dead
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


public func ==(lhs : Board,rhs : Board ) -> Bool {
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


extension Board : Equatable { }


var b = Board(rows: 10, columns: 10)
let b2 = Board(rows: 10, columns: 10)
b = b2.populateBoard()
print(b)

b.livingNeighbours(0,row: 5)
b[0,0]

print(b.processBoard())

class GeneratorTest : GeneratorType {
    typealias Element = Int
    private var s = 0
    private var e = 0;
    init(startIndex:Int,endIndex: Int) {
        s = startIndex
        e = endIndex
    }
    func next() -> Int? {
        return s<=e ? s++ : nil
    }
}

class GeneratorTestSequence : SequenceType {
    func generate() -> GeneratorTest {
        return GeneratorTest(startIndex:0,endIndex:1000)
    }
    
}


let g = GeneratorTestSequence().generate()

print(g.next())
print(g.next())
print(g.next())

var ll : String = ""
for i in GeneratorTestSequence() {
    ll += "\(i)"
}
print(ll)
let k = arc4random()%2





