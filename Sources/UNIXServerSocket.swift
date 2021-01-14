import Foundation
#if os(Linux)
import Glibc
private let system_accept = Glibc.accept
private let system_listen = Glibc.listen
private let sock_stream = Int32(SOCK_STREAM.rawValue)
private let system_bind = Glibc.bind
#else
import Darwin
private let system_accept = Darwin.accept
private let system_listen = Darwin.listen
private let sock_stream = SOCK_STREAM
private let system_bind = Darwin.bind
#endif


public class UNIXServerSocket: UNIXSocket, Listener {
    
    override public init(path: URL) throws {
        try super.init(path: path)
        
        do {
            try bind(path)
        } catch {
            try close()
            throw error
        }
    }
    
    private func bind(_ path: URL) throws {
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        
        let lengthOfPath = path.relativePath.withCString { Int(strlen($0)) }
        
        guard lengthOfPath < MemoryLayout.size(ofValue: addr.sun_path) else {
            throw UNIXSocketError(kind: .pathLength, message: "Path too long!")
        }
        
        _ = withUnsafeMutablePointer(to: &addr.sun_path.0) { ptr in
            path.relativePath.withCString {
                strncpy(ptr, $0, lengthOfPath)
            }
        }
        
        try withUnsafePointer(to: &addr) {
            try $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                guard system_bind(fileNumber, $0, UInt32(MemoryLayout<sockaddr_un>.stride)) != -1 else {
                    throw UNIXSocketError(kind: .bindError, errno: errno)
                }
            }
        }
    }
    
    private func listen(backlog: Int32) throws {
        guard system_listen(fileNumber, backlog) != -1 else {
            throw UNIXSocketError(kind: .listenError, errno: errno)
        }
    }
    
    /// Accepts a connection socket
    public func accept() throws -> UNIXConnection {
        let fileNumber = system_accept(self.fileNumber, nil, nil)
        guard fileNumber != -1 else {
            throw UNIXSocketError(kind: .acceptError, errno: errno)
        }
        
        return UNIXConnection(fileNumber: fileNumber)
    }
}
