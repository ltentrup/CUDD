import XCTest
@testable import CUDD

class CUDDTests: XCTestCase {
    func testInitialization() {
        let manager = CUDDManager()
    }
    
    func testOneEqual() {
        let manager = CUDDManager()
        let a = manager.one()
        let b = manager.one()
        XCTAssertEqual(a, b, "Constant one functions should be equal")
    }
    
    func testOneZeroUnequal() {
        let manager = CUDDManager()
        let a = manager.one()
        let b = manager.zero()
        XCTAssertNotEqual(a, b, "true != false")
        XCTAssertEqual(a & b, b, "true & false == false")
    }
    
    func testConjunction() {
        let manager = CUDDManager()
        var a = manager.newVar()
        var b = manager.newVar()
        
        let aCopy = a
        let bCopy = b
        
        XCTAssertNotEqual(a, b, "Two freshly generated variables should not be equal")
        a &= b
        XCTAssertNotEqual(a, b, "(a & b) != b")
        b &= a
        XCTAssertEqual(a, b, "(a & b) = (a & b)")
        
        let c = aCopy & bCopy
        XCTAssertEqual(c, a, "(a & b) = (a & b)")
    }
    
    func testNegation() {
        let manager = CUDDManager()
        let a = manager.newVar()
        XCTAssertNotEqual(a, !a, "a != !a")
        XCTAssertEqual(a, !(!a), "a == !!a")
        XCTAssertTrue((!a).isComplement())
    }
    
    func testXnor() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        XCTAssertEqual(a <-> b, b <-> a, "(a <-> b) == (b <-> a)")
    }
    
    func testAbstraction() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let function = a & b
        XCTAssertEqual(function.ExistAbstract(cube: a & b), manager.one(), "∃ a, b. (a & b) == true")
        XCTAssertEqual(function.UnivAbstract(cube: a), manager.zero(), "∀ a. (a & b) == false")
    }
    
    func testAndAbstraction() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        XCTAssertEqual(a.AndAbstract(with: b, cube: a & b), manager.one(), "∃ a, b. (a & b) == true")
        XCTAssertEqual(a.AndAbstract(with: b, cube: a), b, "∃ a. (a & b) == b")
        XCTAssertEqual(a.AndAbstract(with: b, cube: b), a, "∃ b. (a & b) == a")
    }
    
    func testVectorCompose() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let c = manager.newVar()
        let d = manager.newVar()
        let function = a & b
        let composed = function.compose(vector: [a, c & d, c, d])
        XCTAssertEqual(composed, a & c & d)
    }
    
    func testVarMapping() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let c = manager.newVar()
        let d = manager.newVar()
        manager.setVarMap(from: [a, b, c, d], to: [c, d, a, b])
        
        let function = a & b
        let function2 = c & d
        XCTAssertNotEqual(function, function2, "(a & b) != (c & d)")
        let primedFunction = function.varMap()
        XCTAssertNotEqual(primedFunction, function, "(a & b)[a<->c,b<->d] != (a & b)")
        XCTAssertEqual(primedFunction, function2, "(a & b)[a<->c,b<->d] == (c & d)")
        let doublePrimedFunction = primedFunction.varMap()
        XCTAssertEqual(doublePrimedFunction, function, "(a & b)[a<->c,b<->d][a<->c,b<->d] == (a & b)")
    }
    
    func testIndex() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        XCTAssertEqual(a.index(), 0, "index(a) -> 0")
        XCTAssertEqual(b.index(), 1, "index(b) -> 1")
    }
    
    func testVariableMetaInformation() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let c = manager.newVar()
        
        XCTAssertFalse(a.isPresentState())
        a.setPresentState()
        XCTAssertTrue(a.isPresentState())
        XCTAssertFalse(b.isNextState())
        
        XCTAssertFalse(b.isNextState())
        b.setNextState()
        XCTAssertTrue(b.isNextState())
        XCTAssertFalse(b.isPresentState())
        XCTAssertFalse(b.isPrimaryInput())
        
        a.setPair(nextState: b)
        
        //XCTAssertFalse(c.isPrimaryInput())
        c.setPrimaryInput()
        XCTAssertTrue(c.isPrimaryInput())
    }
    
    func testLessOrEqual() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        XCTAssertFalse(a <= b)
        let function = !a & !b
        XCTAssertTrue(function <= !a)
        XCTAssertTrue(!a >= function)
    }
    
    func testCoFactor() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        // f: a -> b
        let function = (!a | b)
        XCTAssertEqual(function.coFactor(withRespectTo: b), manager.one())
        XCTAssertEqual(function.coFactor(withRespectTo: !b), !a)
    }
    
    func testRestrict() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let function = a | b
        XCTAssertEqual(function.restrict(with: !b), a)
    }
    
    static var allTests : [(String, (CUDDTests) -> () throws -> Void)] {
        return [
            ("testInitialization", testInitialization),
            ("testOneEqual", testOneEqual),
            ("testOneZeroUnequal", testOneZeroUnequal),
            ("testConjunction", testConjunction),
            ("testNegation", testNegation),
            ("testXnor", testXnor),
            ("testAbstraction", testAbstraction),
            ("testAndAbstraction", testAndAbstraction),
            ("testVectorCompose", testVectorCompose),
            ("testVarMapping", testVarMapping),
            ("testIndex", testIndex),
            ("testVariableMetaInformation", testVariableMetaInformation),
            ("testLessOrEqual", testLessOrEqual),
            ("testCoFactor", testCoFactor),
            ("testRestrict", testRestrict),
        ]
    }
}
