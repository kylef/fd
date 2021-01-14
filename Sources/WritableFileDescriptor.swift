import Foundation
#if os(Linux)
import Glibc
private let system_write = Glibc.write
#else
import Darwin
private let system_write = Darwin.write
#endif

public protocol WritableFileDescriptor : FileDescriptor {}

extension WritableFileDescriptor {
    /// Write attemps to write the given bytes to the file descriptor
    public func write(_ bytes: [Byte]) throws -> Int {
        let size = system_write(fileNumber, bytes, bytes.count)
        
        guard size != -1 else {
            throw FileDescriptorError(kind: .writeError, errno: errno)
        }
        
        return size
    }
    
    /// Write attemps to write the given data to the file descriptor
    public func write(_ data: Data) throws -> Int {
        let bytes = [Byte](data)
        
        return try write(bytes)
    }
}
