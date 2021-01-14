import Foundation
#if os(Linux)
import Glibc
private let system_read = Glibc.read
#else
import Darwin
private let system_read = Darwin.read
#endif

public protocol ReadableFileDescriptor : FileDescriptor {}

extension ReadableFileDescriptor {
    /// Read attempts to read the given size from the file descriptor
    public func read(_ bufferSize: Int) throws -> [Byte] {
        let buffer = UnsafeMutableRawPointer(malloc(bufferSize))
        defer { free(buffer) }
        let size = system_read(fileNumber, buffer!, bufferSize)
        
        guard size != -1 else {
            throw FileDescriptorError(kind: .readError, errno: errno)
        }
        
        let readSize = min(size, bufferSize)
        var bytes = [Byte](repeating: 0, count: readSize)
        memcpy(&bytes, buffer!, readSize)
        return bytes
    }
    
    /// Read attempts to read the given size from the file descriptor
    public func read(_ bufferSize: Int) throws -> Data {
        let bytes: [Byte] = try read(bufferSize)
        
        return Data(bytes: bytes, count: bytes.count)
    }
    
    public func readAll() throws -> Data {
        var result = Data()
        var data = CChar()
        var data_read: size_t
        
        while (((data_read = recv(fileNumber, &data, 1, 0)), data_read > 0).1 && !Character(UnicodeScalar(UInt8(bitPattern: data))).isNewline) {
            result.append(contentsOf: [data].map(UInt8.init))
        }
        
        guard data_read != -1 else {
            throw FileDescriptorError(kind: .unknown, errno: errno)
        }
        
        return result
    }
}
