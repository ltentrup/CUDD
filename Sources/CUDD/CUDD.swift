import CCUDD
//import CCUDDAdditional

public enum CUDDReordering {
    case Same
    case GroupSift
    case LazySift
    
    var cRepresentation: Cudd_ReorderingType {
        switch self {
        case .Same:
            return CUDD_REORDER_SAME
        case .GroupSift:
            return CUDD_REORDER_GROUP_SIFT
        case .LazySift:
            return CUDD_REORDER_LAZY_SIFT
        }
    }
}

public struct CUDDManager {
    
    let manager: OpaquePointer
    
    public init() {
        manager = Cudd_Init(0, 0, UInt32(CUDD_UNIQUE_SLOTS), UInt32(CUDD_CACHE_SLOTS), 0)
    }
    
    public func one() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_ReadOne(manager))
    }
    
    public func zero() -> CUDDNode {
        return CUDDNode(manager: self, node: Cudd_Not(Cudd_ReadOne(manager)))
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
    
    public func AutodynEnable(reorderingAlgorithm: CUDDReordering) {
        Cudd_AutodynEnable(manager, reorderingAlgorithm.cRepresentation)	
    }
    
    public func printInfo() {
        Cudd_PrintInfo(manager, stdout)
    }
}

public class CUDDNode: Equatable, Hashable, CustomStringConvertible {
    let manager: CUDDManager
    var node: OpaquePointer
    fileprivate init(manager: CUDDManager, node: OpaquePointer) {
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
    
    public var hashValue: Int {
        let index: Int = self.index()
        return index.hashValue
    }
    
    public func copy() -> CUDDNode {
        return CUDDNode(manager: manager, node: node)
    }
    
    public func negate() -> CUDDNode {
        node = Cudd_Not(node)
        return self
    }
    
    public func ExistAbstract(cube: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        let result = Cudd_bddExistAbstract(mgr, node, cube.node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func AndAbstract(with: CUDDNode, cube: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        let result = Cudd_bddAndAbstract(mgr, node, with.node, cube.node)
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
    
    public func compose(vector: [CUDDNode]) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        var vector_: [OpaquePointer?] = vector.map({ node in node.node })
        let result = Cudd_bddVectorCompose(mgr, node, &vector_)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func coFactor(withRespectTo other: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        let result = Cudd_Cofactor(mgr, node, other.node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func restrict(with: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = manager.manager
        let result = Cudd_bddRestrict(mgr, node, with.node)
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
    
    public func dagSize() -> Int {
        return Int(Cudd_DagSize(node))
    }
    
    public func setNextState() {
        Cudd_bddSetNsVar(manager.manager, self.index())
    }
    
    public func isNextState() -> Bool {
        return Cudd_bddIsNsVar(manager.manager, self.index()) == 1
    }
    
    public func setPresentState() {
        Cudd_bddSetPsVar(manager.manager, self.index())
    }
    
    public func isPresentState() -> Bool {
        return Cudd_bddIsPsVar(manager.manager, self.index()) == 1
    }
    
    public func setPrimaryInput() {
        Cudd_bddSetPiVar(manager.manager, self.index())
    }
    
    public func isPrimaryInput() -> Bool {
        return Cudd_bddIsPiVar(manager.manager, self.index()) == 1
    }
    
    public func setPair(nextState: CUDDNode) {
        Cudd_bddSetPairIndex(manager.manager, self.index(), nextState.index())
    }
    
    public func thenChild() -> CUDDNode {
        let result = Cudd_T(node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func elseChild() -> CUDDNode {
        let result = Cudd_E(node)
        //checkReturnValue(result);
        return CUDDNode(manager: manager, node: result!)
    }
    
    public func isComplement() -> Bool {
        return Cudd_IsComplement(node) == 1
    }
    
    // Operator declarations
    public static func ==(lhs: CUDDNode, rhs: CUDDNode) -> Bool {
        return lhs.node == rhs.node
    }

    public static func &(lhs: CUDDNode, rhs: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = lhs.manager.manager
        let result = Cudd_bddAnd(mgr, lhs.node, rhs.node)
        //checkReturnValue(result);
        return CUDDNode(manager: lhs.manager, node: result!)
    }

    public static func &=(lhs: inout CUDDNode, rhs: CUDDNode) {
        //DdManager *mgr = checkSameManager(other);
        let mgr = lhs.manager.manager
        let result = Cudd_bddAnd(mgr, lhs.node, rhs.node)
        //checkReturnValue(result);
        Cudd_Ref(result)
        Cudd_RecursiveDeref(mgr, lhs.node)
        lhs.node = result!
    }

    public static func |(lhs: CUDDNode, rhs: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = lhs.manager.manager
        let result = Cudd_bddOr(mgr, lhs.node, rhs.node)
        //checkReturnValue(result);
        return CUDDNode(manager: lhs.manager, node: result!)
    }

    public prefix static func !(operand: CUDDNode) -> CUDDNode {
        return CUDDNode(manager: operand.manager, node: Cudd_Not(operand.node))
    }

    public static func <->(lhs: CUDDNode, rhs: CUDDNode) -> CUDDNode {
        //DdManager *mgr = checkSameManager(other);
        let mgr = lhs.manager.manager
        let result = Cudd_bddXnor(mgr, lhs.node, rhs.node)
        //checkReturnValue(result);
        return CUDDNode(manager: lhs.manager, node: result!)
    }

    public static func <=(lhs: CUDDNode, rhs: CUDDNode) -> Bool {
        //DdManager *mgr = checkSameManager(other);
        let mgr = lhs.manager.manager
        let result = Cudd_bddLeq(mgr, lhs.node, rhs.node)
        return result == 1
    }

    public static func >=(lhs: CUDDNode, rhs: CUDDNode) -> Bool {
        //DdManager *mgr = checkSameManager(other);
        let mgr = lhs.manager.manager
        let result = Cudd_bddLeq(mgr, rhs.node, lhs.node)
        return result == 1
    }
}

infix operator <->
