//
//  Concept_MapTests.swift
//  Concept MapTests
//
//  Created by 澁谷悠大 on 2022/04/14.
//

import XCTest
@testable import Concept_Map

class Concept_MapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateEdge() throws {
        // エッジが正しく生成されるか確認
        //　有向エッジ、無向エッジ両方確認
        let springmodel = SpringModel()
        let node1 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node1")
        let node2 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node2")
        
        let edge1 = springmodel.createEdge(startNode: node1, endNode: node2)
        let edge2 = springmodel.createEdge(startNode: node1, endNode: node2, direction: true)
        XCTAssertEqual(edge1.toString(), "node1 --- node2")
        XCTAssertEqual(edge2.toString(), "node1 --> node2")
    }
    func testIsLinkedNode() throws {
        // ２つのノードが接続しているか確認する
        let springmodel = SpringModel()
        let node1 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node1")
        let node2 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node2")
        let node3 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node3")
        
        springmodel.createEdge(startNode: node1, endNode: node2)
        springmodel.createEdge(startNode: node2, endNode: node3, direction: true)
        
        XCTAssertTrue(springmodel.isLinked(startNode: node1, endNode: node2))
        XCTAssertTrue(springmodel.isLinked(startNode: node2, endNode: node3))
        XCTAssertFalse(springmodel.isLinked(startNode: node3, endNode: node1))
        XCTAssertFalse(springmodel.isLinked(startNode: node1, endNode: node1))
    }
    
    func testCalcForce() throws {
        let springmodel = SpringModel()
        let node1 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node1")
        let node2 = springmodel.createNode(origin: CGPoint(x:10, y:0), name: "node2")
        let node3 = springmodel.createNode(origin: CGPoint(x:100, y:0), name: "node3")
        let node4 = springmodel.createNode(origin: CGPoint(x:100, y:100), name: "node4")
        
        //バネの自然長と距離が一致する時
        XCTAssertTrue(springmodel.springForce(startNode: node1, endNode: node2).equals(vector: CGVector(dx: 0, dy: 0)))
        //バネの自然長と距離が一致しない時
        debugPrint(springmodel.springForce(startNode: node1, endNode: node3))
        XCTAssertTrue(springmodel.springForce(startNode: node1, endNode: node3).equals(vector: CGVector(dx: 1, dy: 0)))
        
    }
    
    func testCalculationPoint() throws {
        let springmodel = SpringModel()
        let node1 = springmodel.createNode(origin: CGPoint(x:0, y:0), name: "node1")
        let node2 = springmodel.createNode(origin: CGPoint(x:10, y:0), name: "node2")
        let node3 = springmodel.createNode(origin: CGPoint(x:100, y:0), name: "node3")
        let node4 = springmodel.createNode(origin: CGPoint(x:100, y:100), name: "node4")
        
        springmodel.createEdge(startNode: node1, endNode: node2)
        springmodel.createEdge(startNode: node2, endNode: node4, direction: true)
        
        springmodel.calculation()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
