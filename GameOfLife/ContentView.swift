//
//  ContentView.swift
//  GameOfLife
//
//  Created by Frank Saar on 23/01/2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    private let boardPublisher = GOLBoardPublisher()
    @State var board : GOLBoard? = nil
    let spacing =  5
    
    var body: some View {
        VStack {
            if let board {
                let cellWidth = 40
                GOLBoardView(board: board,
                             spacing: spacing,
                             size: CGSize(width: cellWidth, height: cellWidth))
                    .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: board)
                    
            }
            else {
                Text(LocalizedStringKey("Initialising ...")).font(.headline).background(.white)
            }
        }
        .onReceive(self.boardPublisher.board) { board in
            guard let board = board else {
                return
            }
            if board != self.board  {
                self.board = board
            } else {
                self.board = nil
                boardPublisher.reset()
            }
            
        }
    }
}

#Preview {
    ContentView()
}
