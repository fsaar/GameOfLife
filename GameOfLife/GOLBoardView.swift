
import Foundation
import SwiftUI


struct GOLBoardView: View {
   
    let board : GOLBoard
    let spacing : Int
    let size : CGSize
   
    private var image : some View {
        Image(uiImage: UIImage.orb)
            .resizable()
            .foregroundStyle(.tint)
    }
   
    var body: some View {
        Grid(horizontalSpacing: CGFloat(spacing),verticalSpacing: CGFloat(spacing)) {
            ForEach(0..<board.rows,id: \.self) { row in
                GridRow {
                    ForEach(0..<board.columns,id: \.self) { col in
                        let state = board[col,row]
                        let isAlive = state?.isAlive == true
                        let scale = isAlive  ? 1.0 : 0.01
                        
                        image
                            .frame(width: CGFloat(size.width),height:CGFloat(size.height))
                            .scaleEffect(CGSize(width: scale, height: scale))
                            .tint(isAlive ? .green : .gray)
                    }
                }
            }
        }
    }
}
