import Foundation
#if os(Linux)
import Glibc
private let system_accept = Glibc.accept
private let system_listen = Glibc.listen
private let system_connect = Glibc.connect
#else
import Darwin
private let system_accept = Darwin.accept
private let system_listen = Darwin.listen
private let system_connect = Darwin.connect
#endif

public class UNIXClientSocket: UNIXSocket, Listener {
    
    override public init(path: URL) throws {
        try super.init(path: path)
        
        do {
            try connect(path)
        } catch {
            try close()
            throw error
        }
    }
    
    private func connect(_ path: URL) throws {
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        
        let lengthOfPath = path.relativePath.withCString { Int(strlen($0)) }
        
        guard lengthOfPath < MemoryLayout.size(ofValue: addr.sun_path) else {
            throw UNIXSocketError(kind: .pathLength, message: "Path too long!")
        }
        
        _ = withUnsafeMutablePointer(to: &addr.sun_path.0) { pointer in
            path.relativePath.withCString {
                strncpy(pointer, $0, lengthOfPath)
            }
        }
        
        try withUnsafePointer(to: &addr) { pointer in
            try pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                guard system_connect(fileNumber, $0, UInt32(MemoryLayout<sockaddr_un>.stride)) != -1 else {
                    throw UNIXSocketError(kind: .connectError, errno: errno)
                }
            }
        }
    }
    
    public func accept() throws -> UNIXConnection {
        return UNIXConnection(fileNumber: fileNumber)
    }
}
