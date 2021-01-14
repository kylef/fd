#if os(Linux)
import Glibc
private let system_select = Glibc.select
#else
import Darwin
private let system_select = Darwin.select
#endif


func filter<T : FileDescriptor>(_ sockets: [T]?, _ set: inout fd_set) -> [T] {
    return sockets?.filter {
        fdIsSet($0.fileNumber, &set)
        } ?? []
}


public func select<R : FileDescriptor, W : WritableFileDescriptor, E : FileDescriptor>(reads: [R] = [], writes: [W] = [], errors: [E] = [], timeout: timeval? = nil) throws -> (reads: [R], writes: [W], errors: [E]) {
    var readFDs = fd_set()
    fdZero(&readFDs)
    reads.forEach { fdSet($0.fileNumber, &readFDs) }
    
    var writeFDs = fd_set()
    fdZero(&writeFDs)
    writes.forEach { fdSet($0.fileNumber, &writeFDs) }
    
    var errorFDs = fd_set()
    fdZero(&errorFDs)
    errors.forEach { fdSet($0.fileNumber, &errorFDs) }
    
    let readFDNumbers = reads.map { $0.fileNumber }
    let writeFDNumbers = writes.map { $0.fileNumber }
    let errorFDNumbers = errors.map { $0.fileNumber }
    let maxFD = (readFDNumbers + writeFDNumbers + errorFDNumbers).reduce(0, max)
    let result: Int32
    if var timeout = timeout {
        result = system_select(maxFD + 1, &readFDs, &writeFDs, &errorFDs, &timeout)
    } else {
        result = system_select(maxFD + 1, &readFDs, &writeFDs, &errorFDs, nil)
    }
    
    if result == 0 {
        return ([], [], [])
    } else if result > 0 {
        return (
            filter(reads, &readFDs),
            filter(writes, &writeFDs),
            filter(errors, &errorFDs)
        )
    }
    
    throw FileDescriptorError(kind: .selectError, errno: errno)
}
