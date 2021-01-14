#if os(Linux)
import Glibc
private let system_pipe = Glibc.pipe
#else
import Darwin
private let system_pipe = Darwin.pipe
#endif


class PipeReadFileDescriptor : ReadableFileDescriptor {
    let fileNumber: FileNumber
    
    init(fileNumber: FileNumber) {
        self.fileNumber = fileNumber
    }
    
    deinit {
        let _ = try? close()
    }
}


class PipeWriteFileDescriptor : WritableFileDescriptor {
    let fileNumber: FileNumber
    
    init(fileNumber: FileNumber) {
        self.fileNumber = fileNumber
    }
    
    deinit {
        let _ = try? close()
    }
}


public func pipe() throws -> (reader: ReadableFileDescriptor, writer: WritableFileDescriptor) {
    var fileNumbers: [FileNumber] = [0, 0]
    if system_pipe(&fileNumbers) == -1 {
        throw FileDescriptorError(kind: .pipeError, errno: errno)
    }
    return (PipeReadFileDescriptor(fileNumber: fileNumbers[0]), PipeWriteFileDescriptor(fileNumber: fileNumbers[1]))
}
