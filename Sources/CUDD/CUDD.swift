import CCUDD
import CCUDDAdditional

public enum CUDDReordering {
    case Same
    case LazySift
    
    var cRepresentation: Cudd_ReorderingType {
        switch self {
        case .Same:
            return CUDD_REORDER_SAME
        case .LazySift:
            return CUDD_REORDER_LAZY_SIFT
        }
    }
}

public struct CUDDManager {
    
    let manager: OpaquePointer
    
    public init() {
        manager = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0)
    }
    
    public func one() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_ReadOne(manager))
    }
    
    public func zero() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_Not_(Cudd_ReadOne(manager)))
    }
    
    public func newVar() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_bddNewVar(manager))
    }
    
    public func setVarMap(from: [CUDDNode], to: [CUDDNode]) {
        precondition(from.count == to.count)
        var x: [OpaquePointer?] = from.map({ node in node.node })
        var y: [OpaquePointer?] = to.map({ node in node.node })
        let res = Cudd_SetVarMap(manager, &x, &y, Int32(x.count))
        assert(res == 1)
    }
    
    public func AutodynEnable(reorderingAlgorthm: CUDDReordering) {
        Cudd_AutodynEnable(manager, reorderingAlgorthm.cRepresentation)	
    }
}

public class CUDDNode: Equatable, CustomStringConvertible {
    let manager: CUDDManager
    var node: OpaquePointer
    private init(manager: CUDDManager, node: OpaquePointer) {
        self.manager = manager
        self.node = node
        Cudd_Ref(node)
    }
    deinit {
        Cudd_RecursiveDeref(manager.manager, node)
    }
    
    public var description: String {
        return "\(self.node)"
    }
    
    public func copy() -> CUDDNode {
        return CUDDNode(manager: manager, node: node)
    }
    
    public func negate() -> CUDDNode {
        node = Cudd_Not_(node)
        return self
    }
    
    public func ExistAbstract(cube: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        let result = Cudd_bddExistAbstract(mgr, node, cube.node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func UnivAbstract(cube: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        let result = Cudd_bddUnivAbstract(mgr, node, cube.node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func varMap() -> CUDDNode {
        let mgr = manager.manager
        let result = Cudd_bddVarMap(mgr, node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func PrintMinterm() {
        Cudd_PrintMinterm(manager.manager, node)
    }
    
    public func index() -> UInt32 {
        return Cudd_NodeReadIndex(node)
    }
    public func index() -> Int32 {
        return Int32(Cudd_NodeReadIndex(node))
    }
    public func index() -> Int {
        return Int(Cudd_NodeReadIndex(node))
    }
    
    public func setNextStep() {
        Cudd_bddSetNsVar(manager.manager, self.index())
    }
    
    public func isNextStep() -> Bool {
        return Cudd_bddIsNsVar(manager.manager, self.index()) == 1
    }
    
    public func setPresentStep() {
        Cudd_bddSetPsVar(manager.manager, self.index())
    }
    
    public func isPresentStep() -> Bool {
        return Cudd_bddIsPsVar(manager.manager, self.index()) == 1
    }
    
    public func setPrimaryInput() {
        Cudd_bddSetPiVar(manager.manager, self.index())
    }
    
    public func isPrimaryInput() -> Bool {
        return Cudd_bddIsPiVar(manager.manager, self.index()) == 1
    }
    
    public func setPair(nextStep: CUDDNode) {
        Cudd_bddSetPairIndex(manager.manager, self.index(), nextStep.index())
    }
}

public func ==(lhs: CUDDNode, rhs: CUDDNode) -> Bool {
    return lhs.node == rhs.node
}

public func &(lhs: CUDDNode, rhs: CUDDNode) -> CUDDNode {
    //DdManager *mgr = checkSameManager(other);
    let mgr = lhs.manager.manager
    let result = Cudd_bddAnd(mgr, lhs.node, rhs.node)
    //checkReturnValue(result);
    return CUDDNode(manager: lhs.manager, node: result!)
}

public func &=(lhs: inout CUDDNode, rhs: CUDDNode) {
    //DdManager *mgr = checkSameManager(other);
    let mgr = lhs.manager.manager
    let result = Cudd_bddAnd(mgr, lhs.node, rhs.node)
    //checkReturnValue(result);
    Cudd_Ref(result)
    Cudd_RecursiveDeref(mgr, lhs.node)
    lhs.node = result!
}

public func |(lhs: CUDDNode, rhs: CUDDNode) -> CUDDNode {
    //DdManager *mgr = checkSameManager(other);
    let mgr = lhs.manager.manager
    let result = Cudd_bddOr(mgr, lhs.node, rhs.node)
    //checkReturnValue(result);
    return CUDDNode(manager: lhs.manager, node: result!)
}

public prefix func !(operand: CUDDNode) -> CUDDNode {
    return CUDDNode(manager: operand.manager, node: Cudd_Not_(operand.node))
}

infix operator <-> {}
public func <->(lhs: CUDDNode, rhs: CUDDNode) -> CUDDNode {
    //DdManager *mgr = checkSameManager(other);
    let mgr = lhs.manager.manager
    let result = Cudd_bddXnor(mgr, lhs.node, rhs.node)
    //checkReturnValue(result);
    return CUDDNode(manager: lhs.manager, node: result!)
}