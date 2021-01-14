public class UNIXConnection : FileDescriptor, Connection {
    public let fileNumber: FileNumber
    
    init(fileNumber: FileNumber) {
        self.fileNumber = fileNumber
    }
}
