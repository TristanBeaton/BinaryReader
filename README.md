# BinaryReader

Binary Reader a tool for reading binary files.

## Usage

Begin by making your file API conform to BinaryReadable.

### BinaryReadable

    extension FileHandle: BinaryReadable {
    
        public func readBytes(at offset: UInt, amount: UInt) throws -> Array<UInt8> {
            // Move the file pointer
            self.seek(toFileOffset: UInt64(offset))
            // Read bytes
            let data = readData(ofLength: Int(bitPattern: amount))
            let bytes = Array(data)
            // Check that bytes were read correctly
            guard bytes.count == amount else {
                throw BinaryReadingError.noDataAvailable
            }
            return bytes
        }
    }
    
This allows us to use a FileHandle as our source.

Then reading from the file becomes this easy.

    let filePath = "../data.bin"
    let fileHandle = FileHandle(forReadingAtPath: filePath)!
    
    var reader = BinaryReader(source: fileHandle)
    reader.seek(toBitIndex: 8)
    let firstWord = try reader.readBits(length: 16)

## Features
### File Seeking

BinaryReader supports three ways of file seeking. First of which is seek. This moves the current file pointer to the index specified. As BinaryReader works at the bit level, this examples shows us setting the pointer to the 16th bit which is the start of the third byte.

    reader.seek(to: 16) // moves to the file pointer to the 17th bit (start of the third byte)

Next we have skip. This will move the file pointer forward. This example shows us moving the pointer by 32 bits.

    reader.skip(32) // moves foward 32 bits

Lastly we have rewind. Passing a value to rewind will move the pointer relative to the current pointer position. Not passing a value will move the file pointer to the beginning of the file.

    reader.rewind(8) // moves back 8 bits
    reader.rewind() // moves to start of file
    
### Reading Bits
The purpose of this package is to make it easier to read values that don't fit the usual 8 bit (byte) structure.

    let word = try reader.readBits(length: 16)

This reads 16 bits from the current file position. 
