

import Foundation

enum GOLBoardState : Int {
    case alive = 1
    case dead = 0
        
    var isAlive : Bool {
        self == .alive
    }
    func nextState(with livingNeighbours : Int) -> GOLBoardState {
        // 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        // 2. Any live cell with two or three live neighbours lives on to the next generation.
        // 3. Any live cell with more than three live neighbours dies, as if by over-population.
        // 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
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
