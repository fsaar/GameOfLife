//
//  GameOfLifeTests.swift
//  GameOfLifeTests
//
//  Created by Frank Saar on 23/01/2024.
//

import XCTest
@testable import GameOfLife

fileprivate extension Bool {
    var state : GOLBoardState {
        return self ? .alive : .dead
    }
}

final class GOLBoardIteratorTests: XCTestCase {

   
    func testThatItShouldIterateCorrectly() throws {
        let values : [GOLBoardState] = (0..<30*40).map { _ in Bool.random().state }
        let board = try GOLBoard(columns: 30, rows: 40, values: values)
        var iterator  = GOLBoardIterator(board: board)
        var itvalues : [GOLBoardState] = []
        while let value = iterator.next() {
            itvalues.append(value.state)
        }
        XCTAssertEqual(values, itvalues)
    }
    
    
    
}
