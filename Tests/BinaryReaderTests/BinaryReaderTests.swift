import XCTest
@testable import BinaryReader

final class BinaryReaderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let bytes = Bytes(data: 80, 90, 100, 150)
        var decoder = BinaryReader(source: bytes)
        let bits = try! decoder.readBits(length: 16)
        XCTAssertEqual(bits, UInt(80 << 90))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

private struct Bytes: BinaryReadable {
    
    private var data: [UInt8] = []
    
    init(data: UInt8...) {
        self.data = data
    }
    
    func readBytes(at index: UInt, amount: UInt) throws -> Array<UInt8> {
        var bytes: [UInt8] = []
        
        for i in 0 ..< amount {
            bytes.append(data[Int(index+i)])
        }
        
        return bytes
    }
    
}
