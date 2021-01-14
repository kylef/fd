import Foundation
import Spectre
import fd


public func testUNIXServerSocket() {
    describe("UNIXListener") {
        $0.it("may be initialised with a path") {
            let path = URL(string: "/tmp/fd-unixlistener-test")!
            let listener = try UNIXServerSocket(path: path)
            try expect(listener.fileNumber) != -1
        }
    }
}
