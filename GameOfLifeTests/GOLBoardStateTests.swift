//
//  GameOfLifeTests.swift
//  GameOfLifeTests
//
//  Created by Frank Saar on 23/01/2024.
//

import XCTest
@testable import GameOfLife

final class GOLBoardStateTests: XCTestCase {

    // 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
    // 2. Any live cell with two or three live neighbours lives on to the next generation.
    // 3. Any live cell with more than three live neighbours dies, as if by over-population.
    // 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

    func testThatItShouldReturnTheCorrectStateWhenCellIsAlive() throws {
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 0) == .dead)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 1) == .dead)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 2) == .alive)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 3) == .alive)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 4) == .dead)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 5) == .dead)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 6) == .dead)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 7) == .dead)
        XCTAssertTrue(GOLBoardState.alive.nextState(with: 8) == .dead)

    }
    
    func testThatItShouldReturnTheCorrectStateWhenCellIsDead() throws {
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 0) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 1) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 2) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 3) == .alive)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 4) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 5) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 6) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 7) == .dead)
        XCTAssertTrue(GOLBoardState.dead.nextState(with: 8) == .dead)

    }
    
    func testThatIsShouldReturnTheCorrectStateWhenCallingISAlive() {
        XCTAssertTrue(GOLBoardState.dead.isAlive == false)
        XCTAssertTrue(GOLBoardState.alive.isAlive == true)
    }

    
}
