//
//  springmodel.swift
//  Concept Map
//
//  Created by 澁谷悠大 on 2022/04/16.
//

import SwiftUI



class SpringModel {
    var nodes: [Node] = []
    var edges: [Edge] = []

    //ノード数の取得
    func getNodes() -> [Node]{
        return nodes
    }
    //エッジ数の取得
    func countEdges() {}

    func addNode(node: Node) {
        self.nodes.append(node)
    }

    func convertNodeOrEdge(points: [CGPoint]){
        let radius: Double = 50
        let startPoint: CGPoint = points.first!
        let endPoint: CGPoint   = points.last!
        var nodes_s: [Node] = []
        var nodes_e: [Node] = []
        for node in self.nodes{
            let ds = sqrt(pow(node.origin.x - startPoint.x, 2) + pow(node.origin.y - startPoint.y, 2))
            let de = sqrt(pow(node.origin.x - endPoint.x, 2) + pow(node.origin.y - endPoint.y, 2))
            if (ds < radius){
                nodes_s.append(node)
            }else if(de < radius){
                nodes_e.append(node)
            }
        }
        if(nodes_s.count == 1 && nodes_e.count == 1){
            self.createEdge(startNode: nodes_s.first!, endNode: nodes_e.last!)
        }else{
            self.convertNode(points: points)
        }

    }

    //min, maxのx,y座標の値を取り出す
    func convertNode(points: [CGPoint]) {
        let xArray = points.map(\.x)
        let yArray = points.map(\.y)
        let minX = xArray.min()!
        let maxX = xArray.max()!
        let minY = yArray.min()!
        let maxY = yArray.max()!
        let origin = CGPoint(x: (maxX+minX)/2, y: (maxY+minY)/2)

        self.nodes.append(Node(origin: origin, name: "node_\(self.nodes.count)"))
    }

    //ノードの生成
    func createNode(origin: CGPoint = CGPoint(x: 0, y: 0), name: String = "node") ->Node {
        let node = Node(origin: origin, name: name)
        self.nodes.append(node)
        return node
    }
    //エッジの生成
    func createEdge(startNode: Node, endNode: Node, direction: Bool = false) ->Edge {
        let edge = Edge(startNode: startNode, endNode: endNode, direction: direction)
        self.edges.append(edge)
        print(edge.toString())
        return edge
    }

    func clear(){
        self.nodes.removeAll()
        self.edges.removeAll()
    }

    //2つのNodeが接続しているかどうかを確認
    func isLinked(startNode: Node, endNode: Node) -> Bool {
        var bool = false
        edges.forEach { edge in
            if ((edge.startNode.equals(node: startNode) && edge.endNode.equals(node: endNode)) ||
                (edge.startNode.equals(node: endNode) && edge.endNode.equals(node: startNode))
            ) {
                bool = true
            }
        }
        return bool
    }

    func calculation() {
        let step = 10 //計算回数
        for _ in 1 ... step {
            self.nodes.forEach{n_i in
                self.nodes.forEach{n_j in
                    //print("calculate \(n_i.name) and \(n_j.name)")
                    if (self.isLinked(startNode: n_i, endNode: n_j)){
                        n_i.addDxy(vector: self.springForce(startNode: n_i, endNode: n_j))
                    } else if(!n_i.equals(node: n_j)){
                        n_i.addDxy(vector: self.repulsiveForce(startNode: n_i, endNode: n_j))
                    }
                }
                n_i.calcOrigin()
                //print( n_i.name + ": (" + String(Double(n_i.origin.x)) + ", " + String(Double(n_i.origin.y)) + ")")
            }
            //print("step \(i) ended.\n")
        }

    }

    //スプリングによる力Fs
    // startNodeにかかるFsを算出する
    func springForce(startNode: Node, endNode: Node) -> CGVector{
        let C_s: Double = 10
        let d_0: Double = 100 // not equal 0.
        let dx: Double  = endNode.origin.x - startNode.origin.x
        let dy: Double  = endNode.origin.y - startNode.origin.y
        let d           = sqrt(pow(dx, 2) + pow(dy, 2))
        var ndx: CGFloat = 0
        var ndy: CGFloat = 0
        if (dx != 0) { ndx = CGFloat(dx/fabs(dx)) }
        if (dy != 0) { ndy = CGFloat(dy/fabs(dy)) }
        let n: CGVector = CGVector( dx:ndx, dy:ndy )
        //print("calculate spring force...")
        //print(C_s * log10(d/d_0) * n)
        return C_s * log10(d/d_0) * n
    }

    //被隣接ノード間の斥力Fr
    func repulsiveForce(startNode: Node, endNode: Node) -> CGVector{
        print("\(startNode.name): calculate repulsive force...")
        let C_r: Double = 2000
        let dx: Double  = startNode.origin.x - endNode.origin.x
        let dy: Double  = startNode.origin.y - endNode.origin.y
        let d2           = pow(dx, 2) + pow(dy, 2)
        print("dx: \(dx), dy: \(dy)")
        print(d2)
        var ndx: CGFloat = 0
        var ndy: CGFloat = 0
        if (dx != 0) { ndx = CGFloat(dx/fabs(dx)) }
        if (dy != 0) { ndy = CGFloat(dy/fabs(dy)) }
        let n: CGVector = CGVector( dx:ndx, dy:ndy )
        if d2 != 0{
            print(C_r / d2 * n)
            return C_r / d2 * n
        }else {
            print(C_r * 1000 * n)
            return C_r * 1000 * n
        }
    }
}

// ノード
class Node: Identifiable {
    var id = UUID()
    var name: String
    var origin: CGPoint
    var v: CGVector
    let delta = 0.5

    init(origin: CGPoint = CGPoint(x: 0, y: 0), name: String = "node"){
        self.origin = origin
        self.v = CGVector(dx: 0, dy: 0)
        self.name = name
    }
    //ノードの等価性
    func equals(node: Node) -> Bool{
        return self.id == node.id
    }

    func getName() -> String {
        return self.name
    }

    func addDxy (vector: CGVector) {
        self.v = self.v + vector
    }

    //位置計算
    // self.origin = self.origin + self.v*delta
    func calcOrigin() {
        self.frictionalForce()
        self.origin.x = self.origin.x + self.v.dx * delta
        self.origin.y = self.origin.y + self.v.dy * delta
    }

    //摩擦力
    func frictionalForce() {
        let u:Double = 0.3
        self.addDxy(vector: ((-u) * self.v))
    }
}

// エッジ
class Edge: Identifiable {
    var id = UUID()
    var startNode: Node
    var endNode: Node
    var direction: Bool
    var initialLength: Int = 10

    init(startNode: Node, endNode: Node, direction: Bool = false){
        self.startNode = startNode
        self.endNode = endNode
        self.direction = direction
    }

    func getStartNode() {}
    func getEndNode() {}
    func getDirection() {}
    func getInitialLength() {}
    func toString() -> String {
        if(self.direction){
            return startNode.getName() + " --> " + endNode.getName()
        }else {
            return startNode.getName() + " --- " + endNode.getName()
        }
    }

    func getStartPoint() -> CGPoint{
        return self.startNode.origin
    }
    func getEndPoint() -> CGPoint{
        return self.endNode.origin
    }

}

/**
 extension CGPoint{
     func toString() -> String {
         return (String(self.x) + " " + String(self.y))
     }
 }
 */

extension CGVector {
    /**
    rad回転したベクトル
     */
    func rotate(rad : Double) -> CGVector {
        /**
        回転行列は
            | c  -s | | x |
            | s   c | | y |
         */
        let c: Double = cos(rad)
        let s: Double = sin(rad)
        return CGVector(dx: self.dx*c - self.dy*s, dy: self.dx*s + self.dy*c)
    }
    /**
    長さを返す
     */
    func getLength() -> Double {
        return sqrt(pow(self.dx, 2) + pow(self.dy, 2))
    }

    /**
    ベクトルの等価性チェック
     */
    func equals(vector: CGVector) -> Bool {
        if (self.dx != vector.dx || self.dy != vector.dy){
            return false
        }
        return true
    }

}

func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

func * (left: Double, right: CGVector) -> CGVector {
    return CGVector(dx: left * right.dx, dy: left * right.dy)
}
func * (left: CGVector, right: Double) -> CGVector {
    return CGVector(dx: right * left.dx, dy: right * left.dy)
}
