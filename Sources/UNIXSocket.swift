import Foundation
#if os(Linux)
import Glibc
private let sock_stream = Int32(SOCK_STREAM.rawValue)
#else
import Darwin
private let sock_stream = SOCK_STREAM
#endif

struct UNIXSocketError: Error {
    enum ErrorKind: String {
        case noSocket, creationError, pathLength, bindError, listenError, acceptError, connectError, unknownError
    }
    
    let kind: ErrorKind
    let message: String?
    
    var localizedDescription: String {
        "UNIXSocketError of kind \(kind.rawValue)\(message != nil ? "\nmessage: \(message!)" : "")"
    }
    
    init(kind: ErrorKind, message: String? = nil) {
        self.kind = kind
        self.message = message
    }
    
    init(kind: ErrorKind, errno: Int32) {
        let message = String(utf8String: strerror(errno))
        self.init(kind: kind, message: message)
    }
}

public class UNIXSocket: FileDescriptor {
    public var fileNumber: FileNumber
    
    init(path: URL) throws {
        guard let type = try? path.resourceValues(forKeys: [.fileResourceTypeKey]).fileResourceType, type == .socket else {
            throw UNIXSocketError(kind: .noSocket)
        }
        
        fileNumber = socket(AF_UNIX, sock_stream, 0)
        guard fileNumber != -1 else {
            throw UNIXSocketError(kind: .creationError, errno: errno)
        }
    }
    
    init(kind: Int32) throws {
        fileNumber = socket(kind, sock_stream, 0)
        guard fileNumber != -1 else {
            throw UNIXSocketError(kind: .creationError, errno: errno)
        }
    }
    
    init(fileNumber: FileNumber) {
        self.fileNumber = fileNumber
    }
    
    deinit {
      let _ = try? close()
    }
}
