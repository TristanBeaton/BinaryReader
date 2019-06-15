public protocol BinaryReadable {
    
    func readBytes(at index: UInt, amount: UInt) throws -> Array<UInt8>
}

public struct BinaryReadingError: Error {
    
    public enum Operation {
        case openingFile
        case readingFile
        case seekingFile
    }
    
    public let operation: Operation
    public let description: String?
    
    public init(operation: Operation, description: String? = nil) {
        self.operation = operation
        self.description = description
    }
    
    public static let noDataAvailable = BinaryReadingError(operation: .readingFile, description: "Cannot read outside the bounds of the source data.")
}

public struct BinaryReader {
    // Source of binary data
    private var source: BinaryReadable
    // The current bit index
    private var currentIndex: UInt = 0
    // Create an instance of BinaryReader with a BinaryReadable source.
    public init(source: BinaryReadable) {
        self.source = source
    }
    // This is used internally to read a singular byte at a BYTE index
    private mutating func readByte(at index: UInt) throws -> UInt8 {
        let bytes = try source.readBytes(at: index, amount: 1)
        return bytes[0]
    }
    // This is used internally to read an array of bytes starting at a BYTE index
    private mutating func readBytes(at index: UInt, amount: UInt) throws -> Array<UInt8> {
        let bytes = try source.readBytes(at: index, amount: amount)
        self.currentIndex = (index + amount) * 8
        return bytes
    }
    // Reads bits from the source
    public mutating func readBits(length: UInt) throws -> UInt {
        var bitsToRead = length
        var byteIndex = self.currentIndex / 8
        let bitIndex = self.currentIndex % 8
        let masks = [1, 3, 7, 15, 31, 63, 127, 255] as [UInt8]
        var bitsRead: UInt = 0
        // First Byte
        let amountOfBitsToReadFromTheFirstByte = min(8 - bitIndex, bitsToRead)
        let byte = try readByte(at: byteIndex)
        let mask = masks[Int(7 - bitIndex)]
        bitsRead = UInt(byte & mask)
        if (amountOfBitsToReadFromTheFirstByte != (8 - bitIndex)) {
            bitsRead = bitsRead >> (8 - bitIndex - amountOfBitsToReadFromTheFirstByte)
        }
        byteIndex += 1
        bitsToRead -= amountOfBitsToReadFromTheFirstByte
        // Intermediate Whole Bytes
        while bitsToRead >= 8 {
            bitsRead = bitsRead << 8 | UInt(try readByte(at: byteIndex))
            bitsToRead -= 8
            byteIndex += 1
        }
        // Last Byte
        if bitsToRead > 0 {
            bitsRead = (bitsRead << bitsToRead) | UInt((try readByte(at: byteIndex) >> (8 - bitsToRead)) & masks[Int(bitsToRead - 1)])
        }
        self.currentIndex += length
        return bitsRead
    }
    // This moves the index pointer back
    public mutating func rewind(_ amount: UInt? = nil) {
        self.currentIndex -= amount ?? currentIndex
    }
    // This moves the index pointer forward
    public mutating func skip(_ amount: UInt) {
        self.currentIndex += amount
    }
    // This moves the index pointer to a given index
    public mutating func seek(to index: UInt) {
        self.currentIndex = index
    }
}
