public class TCPConnection : FileDescriptor, Connection {
    public let fileNumber: FileNumber
    
    public init(fileNumber: FileNumber) {
        self.fileNumber = fileNumber
    }
}
