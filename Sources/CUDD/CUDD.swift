import CCUDD
import CCUDDAdditional

public struct CUDDManager {
    
    let manager: OpaquePointer
    
    public init() {
        manager = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0)
    }
    
    public func one() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_ReadOne(manager))
    }
    
    public func zero() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_ReadZero(manager))
    }
    
    public func newVar() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_bddNewVar(manager))
    }
}

public class CUDDNode: Equatable {
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
    
    public func negate() -> CUDDNode {
        node = Cudd_Not_(node)
        return self
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

public prefix func !(operand: CUDDNode) -> CUDDNode {
    return CUDDNode(manager: operand.manager, node: Cudd_Not_(operand.node))
}