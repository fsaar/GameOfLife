//
//  GameOfLifeTests.swift
//  GameOfLifeTests
//
//  Created by Frank Saar on 23/01/2024.
//

import XCTest
@testable import GameOfLife

final class GOLBoardTests: XCTestCase {

   
    func testWhenCallingInitThatItShouldReturnABoardWithTheCorrectSize() throws {
       
        let board1 = try GOLBoard(rows: 3, columns: 4)
        XCTAssertEqual(board1.columns,4)
        XCTAssertEqual(board1.rows,3)
        
        let board2 = try GOLBoard(rows: 5, columns: 8)
        XCTAssertEqual(board2.columns,8)
        XCTAssertEqual(board2.rows,5)
        
        let board3 = try GOLBoard(rows: 9, columns: 9)
        XCTAssertEqual(board3.columns,9)
        XCTAssertEqual(board3.rows,9)
    }
    
    func testWhenCallingInitThatItShouldClearTheBoard() throws {
       
        let board1 = try GOLBoard(rows: 3, columns: 4)
        let aliveStates1  = board1.map { $0.state }.filter { $0.isAlive }
        XCTAssertEqual(aliveStates1.count, 0)
        
        let board2 = try GOLBoard(rows: 3, columns: 4)
        let aliveStates2  = board2.map { $0.state }.filter { $0.isAlive }
        XCTAssertEqual(aliveStates2.count, 0)
    }
    
    func testThatItShouldAddLiveCellsWhenCallingPopulate() throws {
        let board = try GOLBoard(rows: 3, columns: 4)
        let populatedBoard = try board.populateBoard()
        let aliveStates  = populatedBoard.map { $0.state }.filter { $0.isAlive }
        XCTAssertTrue(aliveStates.count > 0)
    }
    
    func testThatWhenCallingProcessItShouldReturnAnUpdatedBoard() throws {
        let board = try GOLBoard(rows: 3, columns: 4).populateBoard()
        let board2 = try board.process()
        XCTAssertTrue(board != board2)
    }
    
    func testEqualityReturnTheCorrectResult() throws {
        let board = try GOLBoard(rows: 3, columns: 4)
        let board2 = try GOLBoard(rows: 3, columns: 4)
        XCTAssertEqual(board,board2)
        
        let board3 = try GOLBoard(rows: 4, columns: 3)
        let board4 = try GOLBoard(rows: 3, columns: 4)
        XCTAssertTrue(board3 != board4)
        
        let board5 = try GOLBoard(rows: 40, columns: 40).populateBoard()
        let board6 = try GOLBoard(rows: 40, columns: 40).populateBoard()
        XCTAssertTrue(board5 != board6)
        
    }
    
    func testSubscriptReturnsTheCorrectResult() throws {
        let board = try GOLBoard(rows: 30, columns: 30).populateBoard().process()
        let states = board.map { $0 }
        let invalidStates = states.filter { board[$0.column,$0.row] != $0.state }
        XCTAssertTrue(invalidStates.isEmpty)
    }
    
    func testThatItShouldThrowWhenInitingWith0ColumnsOrRows()  {
        XCTAssertThrowsError(try GOLBoard(rows: 0, columns: 30))
        XCTAssertThrowsError(try GOLBoard(rows: 30, columns: 0))
    }
    
    
}
