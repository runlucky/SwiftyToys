import Foundation
import Compression

extension String {
    /// 文字列を指定したアルゴリズムで圧縮し、Data型に変換して返します。
    public func compress(_ algorithm: compression_algorithm) -> Data {
        var sourceBuffer =  Array(self.utf8)
        
        let compressedBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.count)
        defer { compressedBuffer.deallocate() }
        
        let compressedSize = compression_encode_buffer(compressedBuffer, self.count,
                                                       &sourceBuffer, self.count,
                                                       nil, algorithm)
        
        return Data(bytes: compressedBuffer, count: compressedSize)
    }
}

extension Data {
    func decompress(_ algorithm: compression_algorithm) -> String {
        let capacity = 8_000_000
        
        let decompressedBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        defer { decompressedBuffer.deallocate() }
        
        let decompressedString = self.withUnsafeBytes { buffer in
            _ = compression_decode_buffer(decompressedBuffer, capacity,
                                          buffer.bindMemory(to: UInt8.self).baseAddress!, self.count,
                                          nil, algorithm)
            
            return String(cString: decompressedBuffer)
            
        }
        
        return decompressedString
    }
}

extension compression_algorithm {
    static var LZ4     : compression_algorithm { COMPRESSION_LZ4 }
    static var ZLIB    : compression_algorithm { COMPRESSION_ZLIB }
    static var LZMA    : compression_algorithm { COMPRESSION_LZMA }
    static var LZ4Raw  : compression_algorithm { COMPRESSION_LZ4_RAW }
    static var LZFSE   : compression_algorithm { COMPRESSION_LZFSE }
    static var BROTLI  : compression_algorithm { COMPRESSION_BROTLI }
    static var LZBITMAP: compression_algorithm { COMPRESSION_LZBITMAP }
}

