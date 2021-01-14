#if os(Linux)
import Glibc
private let system_close = Glibc.close
#else
import Darwin
private let system_close = Darwin.close
#endif


public typealias Byte = UInt8
public typealias FileNumber = Int32


public protocol FileDescriptor {
    var fileNumber: FileNumber { get }
}

struct FileDescriptorError : Error {
    enum ErrorKind: String {
        case readError, writeError, selectError, pipeError, closeError, unknown
    }
    
    let kind: ErrorKind
    let message: String?
    
    var localizedDescription: String {
        "FileDescriptorError of kind \(kind.rawValue)\(message != nil ? "\nmessage: \(message!)" : "")"
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

extension FileDescriptor {
    /// Close deletes the file descriptor from the per-process object reference table
    public func close() throws {
        if system_close(fileNumber) == -1 {
            throw FileDescriptorError(kind: .closeError, errno: errno)
        }
    }
    
    public var isClosed: Bool {
        if fcntl(fileNumber, F_GETFL) == -1 {
            return errno == EBADF
        }
        
        return false
    }
}
