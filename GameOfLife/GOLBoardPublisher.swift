//
//  Generator.swift
//  GameOfLife
//
//  Created by Frank Saar on 24/01/2024.
//

import Foundation
import SwiftUI
import Combine


// TODO: replace orb with particle generator


@Observable
class GOLBoardPublisher  {
    private var cancelableSet = Set<AnyCancellable>()
    private(set) var board = CurrentValueSubject<GOLBoard?,Never>(try? GOLBoardPublisher.newBoard())
    init() {
        Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default).autoconnect().sink { _ in
            if case .none = self.board.value {
                self.board = CurrentValueSubject(try? Self.newBoard())
            }
            if let board = try? self.board.value?.process() {
                self.board.send(board)
            }
           
        }.store(in: &cancelableSet)
    }
    
    func reset() {
        if let board = try? Self.newBoard()  {
            self.board = CurrentValueSubject(board)
        }
       
    }
    
    static func newBoard() throws -> GOLBoard {
        let size: CGSize =  UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?.windows
            .first(where: \.isKeyWindow)?.bounds.size ?? CGSize.zero
  
        let (columns,rows) = (Int(size.width / 40.0),Int(size.height / 40.0))
        return try GOLBoard(rows: rows, columns: columns).populateBoard()
    }
}
