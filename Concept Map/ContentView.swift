//
//  ContentView.swift
//  Concept Map
//
//  Created by 澁谷悠大 on 2022/04/14.
//

import SwiftUI

struct ContentView: View {
    // すでに描いたLine
    @State private var concepts: [Concept] = []
    // TODO：conceptオブジェクトの配列保存
    // TODO：relationオブジェクトの配列保存
    // TODO：currentLineをConceptオブジェクトに変換
    // TODO：currentLineをrelationオブジェクトに変換
    // いまドラッグ中のLine
    @State private var currentLine: DrawLine?
    
    var body: some View {
        VStack {
            // リセットボタン
            Button(action: {
                concepts = []
            }, label: {
                Text("Clear")
            })
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
                                    let concept = DrawLine.convertConcept(points: line.points)
                                    concepts.append(concept)
                                    print(self)
                                    
                                    //各Conceptの座標計算
                                    //原点に負電荷を置く
                                    let midX: CGFloat = geometry.frame(in: .local).width / 2
                                    let midY: CGFloat = geometry.frame(in: .local).height / 2
                                    let chargeOfOrigin = ErectricCharge(origin: CGPoint(x: midX, y: midY), quantity: -1)
                                    
                                    var potentialEnergy: Double = 0
                                    // let accuracy: Double = 100
                                    var count: Int = 0
                                    print("計算開始")
                                    while count < 1000 {
                                        potentialEnergy = 0
                                        concepts.forEach { concept in
                                            print(concept.origin)
                                            concept.a = concept.a + calculateAcceralation(q1: concept, q2: chargeOfOrigin)
                                            let copiedConcepts = concepts
                                            copiedConcepts.forEach { concepted in
                                                if (concept !== concepted){
                                                    concept.a = concept.a + calculateAcceralation(q1: concept, q2: concepted)
                                                    potentialEnergy += calculatePotentialEnergy(q1: concept, q2: concepted)
                                                }
                                            }
                                            concept.calculateVelocity()
                                            concept.calculatePoint()
                                        }
                                        count += 1
                                    }
                                    print("計算終了")
                                    // リセット
                                    currentLine = nil
                                })
                        )
                    Text("X: \(geometry.frame(in: .local).origin.x) Y: \(geometry.frame(in: .local).origin.y) width: \(geometry.frame(in: .local).width) height: \(geometry.frame(in: .local).height)")
                    
                    // 追加ずみのLineの描画
                     ForEach(concepts) { shape in
                         Circle()
                             .fill(Color.red)
                             .frame(width: 10, height: 10)
                             .position(shape.origin)
                     }.clipped()
                    
                    // ドラッグ中のLineの描画
                    Path { path in
                        guard let line = currentLine else { return }
                        path.addLines(line.points)
                    }.stroke(Color.red, lineWidth: 1)
                    .clipped()
                }
                
            }.padding(20)
        }
    }
}
//ポテンシャルエネルギーの計算
func calculatePotentialEnergy(q1: ErectricCharge, q2: ErectricCharge) -> Double {
    let q: Double = q1.quantity * q2.quantity
    let r:Double  = sqrt(pow(q2.origin.x - q1.origin.x, 2) + pow(q2.origin.x - q1.origin.x, 2))
    return q/r
}
//加速度計算
func calculateAcceralation(q1: ErectricCharge, q2: ErectricCharge) -> CGVector {
    // クーロン力
    let q: Double = q1.quantity * q2.quantity
    let vecXC = q*(q1.origin.x - q2.origin.x) / pow(fabs(q1.origin.x - q2.origin.x), 3)
    let vecYC = q*(q1.origin.y - q2.origin.y) / pow(fabs(q1.origin.y - q2.origin.y), 3)
    // 万有引力
    let g = 0.000000000000001
    let vecXG = g * q2.m / pow(q2.origin.x - q1.origin.x, 2)
    let vecYG = g * q2.m / pow(q2.origin.y - q1.origin.y, 2)
    
    print(String(vecXC+vecXG) + "  " + String(vecYC+vecYG))
    return CGVector(dx: vecXC+vecXG, dy: vecYC+vecYG)
}

/**
 func Calculate(q1: ErectricCharge, q2: ErectricCharge, dt: CGFloat) {
     let a = Acceralation(q1: q1, q2: q2)
 }

 */

struct DrawLine: Identifiable {
    var id = UUID()
    var points: [CGPoint] //CGPoint: x,y座標を保存する二次元構造体
    
    static func makeDrawLine(points: [CGPoint]) -> DrawLine {
        let line = DrawLine(points: points)
        return line
    }
    
    static func minCGfloat(lst: [CGFloat]) -> CGFloat{
        let minVal: CGFloat = lst.min()!
        return minVal
    }
    static func maxCGfloat(lst: [CGFloat]) -> CGFloat{
        let maxVal: CGFloat = lst.max()!
        return maxVal
    }
    
    //min, maxのx,y座標の値を取り出す
    static func convertConcept(points: [CGPoint]) -> Concept {
        let xArray = points.map(\.x)
        let yArray = points.map(\.y)
        let minX = minCGfloat(lst: xArray)
        let maxX = maxCGfloat(lst: xArray)
        let minY = minCGfloat(lst: yArray)
        let maxY = maxCGfloat(lst: yArray)

        let origin = CGPoint(x: (maxX+minX)/2, y: (maxY+minY)/2)
        
        // (minX, minY), (maxX, maxY)の座標が少なくとも一方存在するなら一次元図形。そうでないなら二次元図形。
        return Concept(origin: origin, quantity: 1)
    }
    
}

func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}


class ErectricCharge: Identifiable {
    var id = UUID()
    var origin: CGPoint
    var quantity: Double
    var a: CGVector
    var v: CGVector
    let dt: CGFloat = 0.01
    let m: CGFloat = 10
    
    init(origin: CGPoint, quantity: Double){
        self.origin = origin
        self.quantity = quantity
        self.a = CGVector(dx: 0, dy: 0)
        self.v = CGVector(dx: 0, dy: 0)
    }
    
    func calculateVelocity() {
        self.v.dx = self.v.dx + self.a.dx * self.dt
        self.v.dy = self.v.dy + self.a.dy * self.dt
    }

    func calculatePoint() {
        self.origin.x = self.origin.x + self.v.dx * self.dt
        self.origin.y = self.origin.y + self.v.dy * self.dt
    }
}

class Concept: ErectricCharge {
    
    override init(origin: CGPoint, quantity: Double) {
        super.init(origin: origin, quantity: quantity)
        print(self.origin, self.quantity)
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
