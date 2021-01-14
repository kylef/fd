public protocol Listener : FileDescriptor {
    associatedtype AnyConnection
    
    func accept() throws -> AnyConnection
}
