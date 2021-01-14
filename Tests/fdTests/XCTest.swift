import XCTest


class FDTests: XCTestCase {
  func testRunFDTests() {
    testFileDescriptor()
    testPipe()
    testTCPConnection()
    testTCPListener()
    testUNIXConnection()
    testUNIXServerSocket()
  }
}
