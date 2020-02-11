//
//  SearchZone.swift
//  kakaoT_test
//
//  Created by Jang Dong Min on 2020/01/30.
//  Copyright © 2020 Jang Dong Min. All rights reserved.
//

import Foundation
class SearchZone {
    
    public func searching(x: Int, y: Int) -> String? {
        if DataManager.sharedInstance.MeshArr.count > 0 {
            if let mesh = meshSearch(x, y, DataManager.sharedInstance.MeshArr) {
                if let zoneName = zoneSearch(x, y, mesh) {
                    return zoneName
                }
            }
        } else {
            print("data empty")
        }
        return nil
    }
     
    private func meshSearch(_ x: Int, _ y: Int, _ MeshArr: Array<Mesh>) -> Mesh? {
        for i in 0..<MeshArr.count {
            let meshMbr = MeshArr[i].mbr
            if meshMbr.minX <= x && x <= meshMbr.maxX &&
                meshMbr.minY <= y && y <= meshMbr.maxY {
                return MeshArr[i]
            }
        }
        return nil
    }
    
    private func zoneSearch(_ x: Int, _ y: Int, _ mesh: Mesh) -> String? {
        for i in 0..<mesh.ZoneArr.count {
            let zoneMbr = mesh.ZoneArr[i].mbr
            if zoneMbr.minX <= x && x <= zoneMbr.maxX &&
                zoneMbr.minY <= y && y <= zoneMbr.maxY {
                
                if polygonSearch(x, y, mesh.ZoneArr[i]) {
                    DataManager.sharedInstance.selectMeshIndex = mesh.index
                    DataManager.sharedInstance.selectZoneIndex = mesh.ZoneArr[i].index
                    return mesh.ZoneArr[i].ZoneName
                }
            }
        }
        return nil
    }
    
    private func polygonSearch(_ x: Int, _ y: Int, _ zone: Zone) -> Bool {
        if zone.PolygonArr.count > 1 {
            for i in 0..<zone.PolygonArr.count {
                let PolygonMbr = zone.PolygonArr[i].mbr
                if PolygonMbr.minX <= x && x <= PolygonMbr.maxX &&
                    PolygonMbr.minY <= y && y <= PolygonMbr.maxY {
                    
                    let result = isInside(x, y, zone.PolygonArr[i].PointArr)
                    if result {
                        DataManager.sharedInstance.selectPolygonIndex = zone.PolygonArr[i].index
                    }
                    return result
                }
            }
        } else {
            let result = isInside(x, y, zone.PolygonArr[0].PointArr)
            if result {
                DataManager.sharedInstance.selectPolygonIndex = zone.PolygonArr[0].index
            }
            return result
        }
        return false
    }
  
    //x, y 값이 polygon 안에 있는지 판별.
    private func isInside(_ x: Int, _ y: Int, _ p: Array<Point>) -> Bool {
        var crosses = 0
        for i in 0..<p.count {
            let j = (i+1)%p.count
            if (p[i].y > y) != (p[j].y > y) {
                let atX = (p[j].x - p[i].x) * (y - p[i].y) / ( p[j].y - p[i].y) + p[i].x
                if(x < atX) {
                    crosses+=1
                }
            }
        }
        return crosses % 2 > 0
    }
}
