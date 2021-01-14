#if os(Linux)
import Glibc
private let system_pipe = Glibc.pipe
#else
import Darwin
private let system_pipe = Darwin.pipe
#endif

import Spectre
import fd


struct TestFileDescriptor : FileDescriptor, WritableFileDescriptor, ReadableFileDescriptor {
  let fileNumber: FileNumber

  init(fileNumber: FileNumber) {
    self.fileNumber = fileNumber
  }
}


public func testFileDescriptor() {
  describe("FileDescriptor") {
    $0.it("may be closed") {
      let (read, write) = try pipe()

      try expect(read.isClosed).to.beFalse()
      try expect(write.isClosed).to.beFalse()

      try write.close()
      try read.close()

      try expect(read.isClosed).to.beTrue()
      try expect(write.isClosed).to.beTrue()
    }

    $0.it("errors while closing an invalid file descriptor") {
      let descriptor = TestFileDescriptor(fileNumber: -1)
      try expect { try descriptor.close() }.toThrow()
    }
  }

  describe("ReadableFileDescriptor/WritableFileDescriptor") {
    $0.it("may be written to, and read from") {
      let (read, write) = try pipe()
      try expect(try write.write([1, 2, 3])) == 3

      let bytes: [Byte] = try read.read(3)
      try expect(bytes.count) == 3
      try expect(bytes[0]) == 1
      try expect(bytes[1]) == 2
      try expect(bytes[2]) == 3
    }

    $0.it("errors while writing from an invalid file descriptor") {
      let descriptor = TestFileDescriptor(fileNumber: -1)
      try expect { try descriptor.write([1]) }.toThrow()
    }

    $0.it("errors while reading from an invalid file descriptor") {
      let descriptor = TestFileDescriptor(fileNumber: -1)
      try expect { try descriptor.read(1) as [Byte] }.toThrow()
    }
  }
}
