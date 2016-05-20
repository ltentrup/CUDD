import CCUDD

public struct CUDDManager {
    
    let manager: OpaquePointer
    
    public init() {
        manager = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0)
    }
    
    public func One(_: Void) -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_ReadOne(manager))
    }
}

public class CUDDNode: Equatable {
    let manager: CUDDManager
    let node: OpaquePointer
    private init(manager: CUDDManager, node: OpaquePointer) {
        self.manager = manager
        self.node = node
        Cudd_Ref(node)
    }
    deinit {
        Cudd_RecursiveDeref(manager.manager, node)
    }
}

public func ==(lhs: CUDDNode, rhs: CUDDNode) -> Bool {
    return lhs.node == rhs.node
}