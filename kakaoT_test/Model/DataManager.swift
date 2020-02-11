//
//  DataManager.swift
//  kakaoT_test
//
//  Created by Jang Dong Min on 2020/01/30.
//  Copyright © 2020 Jang Dong Min. All rights reserved.
//

import Foundation

struct MBR {
    var minX: Int
    var minY: Int
    var maxX: Int
    var maxY: Int
}

struct Mesh {
    var index: Int //결과 데이터 검증용
    var mbr: MBR
    var ZoneArr = Array<Zone>()
}

struct Zone {
    var index: Int //결과 데이터 검증용
    var ZoneName: String
    var mbr: MBR
    var PolygonArr: Array<PolyGon>
}

struct PolyGon {
    var index: Int //결과 데이터 검증용
    var mbr: MBR
    var PointArr: Array<Point>
}

struct Point {
    var x: Int
    var y: Int
}

class DataManager {
    static let sharedInstance = DataManager()
    
    var byteSize = 1
    var IntSize = 4
    var ShortSize = 2
    
    var Version: Int = 0
    var MapCoverage: MBR = MBR(minX: 0, minY: 0, maxX: 0, maxY: 0)

    var MashCount: Int = 0
    var MeshArr = Array<Mesh>()
    
    var searchZone = SearchZone()
    var verifyZone = VerifyZone()
    
    //verfiy 관련.
    var selectPolygonIndex = 0
    var selectMeshIndex = 0
    var selectZoneIndex = 0
    
    private init() {

    }
    
    public func readDatFile(_ fileName: String) -> Bool {
        if let path = Bundle.main.path(forResource: fileName, ofType: "dat") {
            if let data = NSData(contentsOfFile: path) {
                dataParse(data: data)
                return true
            }
        }
        return false
    }

    //바이트 단위로 데이터를 파싱한다.
    private func dataParse(data: NSData) {
        var offset = 0
        
        var buffer = [UInt8](repeating: 0, count: byteSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, byteSize))
        Version = Data(buffer).toInteger(endian: .big)
        offset += byteSize

        buffer = [UInt8](repeating: 0, count: IntSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
        MapCoverage.minX = Data(buffer).toInteger(endian: .big)
        offset += IntSize
        
        buffer = [UInt8](repeating: 0, count: IntSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
        MapCoverage.minY = Data(buffer).toInteger(endian: .big)
        offset += IntSize
        
        buffer = [UInt8](repeating: 0, count: IntSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
        MapCoverage.maxX = Data(buffer).toInteger(endian: .big)
        offset += IntSize
        
        buffer = [UInt8](repeating: 0, count: IntSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
        MapCoverage.maxY = Data(buffer).toInteger(endian: .big)
        offset += IntSize
        
        buffer = [UInt8](repeating: 0, count: IntSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
        MashCount = Data(buffer).toInteger(endian: .big)
        offset += IntSize
         
        for i in 0..<MashCount {
            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let minX: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize
            
            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let minY: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize

            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let maxX: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize

            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let maxY: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize
            
            MeshArr.append(Mesh(index: i, mbr: MBR(minX: minX, minY: minY, maxX: maxX, maxY: maxY)))
            


            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let MeshDataOffSet: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize
            
            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let MeshDataSize: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize
            
            buffer = [UInt8](repeating: 0, count: MeshDataSize)
            data.getBytes(&buffer, range: NSMakeRange(MeshDataOffSet, MeshDataSize))

            MeshDataParse(NSData(bytes: &buffer, length: MeshDataSize), i)
        }
    }
    
    private func MeshDataParse(_ data: NSData, _ meshIndex: Int) {
        var offset = 0
        var buffer = [UInt8](repeating: 0, count: IntSize)
        data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
        let ZoneCount: Int = Data(buffer).toInteger(endian: .big)
        offset += IntSize
        
        var pointTotalCount = 0
        for zoneIndex in 0..<ZoneCount {
            buffer = [UInt8](repeating: 0, count: IntSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
            let PolygonCount: Int = Data(buffer).toInteger(endian: .big)
            offset += IntSize
             
            var zoneMinX = -1
            var zoneMinY = -1
            var zoneMaxX = -1
            var zoneMaxY = -1
            
            var polyGonArr = Array<PolyGon>()
            
            for polygonIndex in 0..<PolygonCount {
                buffer = [UInt8](repeating: 0, count: ShortSize)
                data.getBytes(&buffer, range: NSMakeRange(offset, ShortSize))
                let PointCount: CShort = Data(buffer).toInteger(endian: .big)
                offset += ShortSize
                pointTotalCount += Int(PointCount)
                
                var polyGonMinX = -1
                var polyGonMinY = -1
                var polyGonMaxX = -1
                var polyGonMaxY = -1
                var pointArr = Array<Point>()
                
                for _ in 0..<PointCount {
                    buffer = [UInt8](repeating: 0, count: IntSize)
                    data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
                    let x: Int = Data(buffer).toInteger(endian: .big)
                    offset += IntSize
                    
                    buffer = [UInt8](repeating: 0, count: IntSize)
                    data.getBytes(&buffer, range: NSMakeRange(offset, IntSize))
                    let y: Int = Data(buffer).toInteger(endian: .big)
                    offset += IntSize
                    
                    if polyGonMinX > x || polyGonMinX == -1 {
                       polyGonMinX = x
                    }
                    
                    if polyGonMaxX < x || polyGonMaxX == -1  {
                       polyGonMaxX = x
                    }
                    
                    if polyGonMinY > y || polyGonMinY == -1 {
                       polyGonMinY = y
                    }
                    
                    if polyGonMaxY < y || polyGonMaxY == -1  {
                       polyGonMaxY = y
                    }
                    
                    pointArr.append(Point(x: x, y: y))
                }
                
                if zoneMinX > polyGonMinX || zoneMinX == -1 {
                    zoneMinX = polyGonMinX
                }
                
                if zoneMaxX < polyGonMaxX || zoneMaxX == -1 {
                   zoneMaxX = polyGonMaxX
                }
                
                if zoneMinY > polyGonMinY || zoneMinY == -1 {
                   zoneMinY = polyGonMinY
                }
                
                if zoneMaxY < polyGonMaxY || zoneMaxY == -1 {
                   zoneMaxY = polyGonMaxY
                }
               
                polyGonArr.append(PolyGon(index: polygonIndex, mbr: MBR(minX: polyGonMinX, minY: polyGonMinY, maxX: polyGonMaxX, maxY: polyGonMaxY), PointArr: pointArr))
            }
            
            buffer = [UInt8](repeating: 0, count: byteSize)
            data.getBytes(&buffer, range: NSMakeRange(offset, byteSize))
            let ZoneNameLength: Int = Data(buffer).toInteger(endian: .big)
            offset += byteSize
            
            buffer = [UInt8](repeating: 0, count: ZoneNameLength)
            data.getBytes(&buffer, range: NSMakeRange(offset, ZoneNameLength))
            
            if let string = String(bytes: buffer, encoding: .utf8) {
                MeshArr[meshIndex].ZoneArr.append(Zone(index: zoneIndex, ZoneName: string, mbr: MBR(minX: zoneMinX, minY: zoneMinY, maxX: zoneMaxX, maxY: zoneMaxY), PolygonArr: polyGonArr))
            }
            offset += ZoneNameLength
        }
    }
}
 
extension Data: IntegerTransform {}
extension Array: IntegerTransform where Element: FixedWidthInteger {}
public enum Endian {
    case big, little
}

protocol IntegerTransform: Sequence where Element: FixedWidthInteger {
    func toInteger<I: FixedWidthInteger>(endian: Endian) -> I
}

extension IntegerTransform {
    func toInteger<I: FixedWidthInteger>(endian: Endian) -> I {
        let f = { (accum: I, next: Element) in accum &<< next.bitWidth | I(next) }
        return endian == .big ? reduce(0, f) : reversed().reduce(0, f)
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
