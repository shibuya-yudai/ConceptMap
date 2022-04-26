//
//  ContentView.swift
//  Concept Map
//
//  Created by 澁谷悠大 on 2022/04/14.
//

import SwiftUI

struct ContentView: View {
    @State var springmodel = SpringModel()
    // すでに描いたLine
    // TODO：conceptオブジェクトの配列保存
    // TODO：relationオブジェクトの配列保存
    // TODO：currentLineをConceptオブジェクトに変換
    // TODO：currentLineをrelationオブジェクトに変換
    // いまドラッグ中のLine
    @State private var currentLine: DrawLine?
    
    var body: some View {
        VStack(spacing : 0) {
            ZStack{
                Rectangle()
                    .fill(Color.green)
                    .border(Color.black, width: 1)
                    .frame(height: 50)
                Button(action: {
                    springmodel.clear()
                }, label: {
                    Text("Clear")
                })
            }
            HStack (spacing : 0){
                ZStack {
                    // Canvas部分
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.white)
                            .border(Color.black, width: 1)
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                   .onChanged({ value in
                                        if currentLine == nil {
                                            currentLine = DrawLine.makeDrawLine(points: [])
                                        }
                                        guard var line = currentLine else { return }
                                        line.points.append(value.location)
                                        currentLine = line
                                    })
                                    .onEnded({ value in
                                        guard var line = currentLine else { return }
                                        line.points.append(value.location)
                                        //手書きを図形に変換
                                        springmodel.convertNodeOrEdge(points: line.points)
                                        
                                        //各Conceptの座標計算
                                        springmodel.calculation()
                                        
                                        // リセット
                                        currentLine = nil
                                    })
                            )
                        
                        
                        // 追加ずみのNodeの描画
                        ForEach(springmodel.nodes) { node in
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 50, height: 50)
                                    .position(node.origin)
                                    .animation(.easeInOut(duration: 1), value: node.origin)
                                Text(node.name)
                                    .position(x: node.origin.x, y: node.origin.y)
                            }
                         }.clipped()
                        
                        //　追加ずみのEdgeの描写
                        //TODO: アニメーションつける、むずい
                        ForEach(springmodel.edges) { edge in
                            Arrow.makeEdge(edge: edge)
                                .stroke()
                                .foregroundColor(.red)
                        }
                        

                        // ドラッグ中のLineの描画
                        Path { path in
                            guard let line = currentLine else { return }
                            path.addLines(line.points)
                        }.stroke(Color.red, lineWidth: 1)
                        .clipped()
                    }
                    
                }
                ZStack{
                    Rectangle()
                        .fill(Color.white)
                        .border(Color.black, width: 1)
                        .frame(minWidth: 0, alignment: .center)
                        
                }
            }
        }
    }
}

struct DrawLine: Identifiable {
    var id = UUID()
    var points: [CGPoint] //CGPoint: x,y座標を保存する二次元構造体
    
    static func makeDrawLine(points: [CGPoint]) -> DrawLine {
        let line = DrawLine(points: points)
        return line
    }
    
    
}

/**
 TODO:
 - nodeオブジェクトの構造体を用意
 - ダブルクリックするとプロパティを変更できる
 */

/**
 TODO:
 - direction: trureなら矢印つける
 - 関係性ごとに矢印の見た目を変更する
 */
struct Arrow: Shape {
    var id = UUID()
    var start: CGPoint
    var end:   CGPoint
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
    static func makeEdge(edge: Edge) -> Arrow{
        let line = Arrow(start: edge.getStartPoint(), end: edge.getEndPoint())
        return line
    }

}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
