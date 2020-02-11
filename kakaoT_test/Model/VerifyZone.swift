//
//  VerifyZone.swift
//  kakaoT_test
//
//  Created by 100282 on 01/02/2020.
//  Copyright © 2020 Jang Dong Min. All rights reserved.
//

import UIKit
import CoreText
import Foundation
class VerifyZone {
    public func verify(x: Int, y: Int, type: Int, view: UIView) {
        if DataManager.sharedInstance.MeshArr.count > 0 {
            if type == 0 {
                // polygon만 그리기
                draw(x, y, view, polyGon: DataManager.sharedInstance.MeshArr[DataManager.sharedInstance.selectMeshIndex].ZoneArr[DataManager.sharedInstance.selectZoneIndex].PolygonArr[DataManager.sharedInstance.selectPolygonIndex],
                     mesh: DataManager.sharedInstance.MeshArr[DataManager.sharedInstance.selectMeshIndex], matching: true)
            } else {
                // mesh 그리기
                let zoneArr = DataManager.sharedInstance.MeshArr[DataManager.sharedInstance.selectMeshIndex].ZoneArr
                
                for i in 0..<zoneArr.count {
                    for j in 0..<zoneArr[i].PolygonArr.count {
                        var matching = false
                        if DataManager.sharedInstance.selectZoneIndex == i {
                            matching = true
                        }
                        draw(x, y, view, polyGon: zoneArr[i].PolygonArr[j], mesh: DataManager.sharedInstance.MeshArr[DataManager.sharedInstance.selectMeshIndex], matching: matching)
                    }
                }
            }
        } else {
            print("data empty")
        }
    }
    
    private func draw (_ x: Int, _ y: Int, _ view: UIView, polyGon: PolyGon, mesh: Mesh, matching: Bool) {
        let ratio = 100
        
        //polygon 을 그린다.
        let shape = CAShapeLayer()
        view.layer.addSublayer(shape)
        shape.lineWidth = 1
        shape.opacity = 1
        
        shape.lineJoin = .miter
 
        if matching {
            shape.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
            shape.fillColor = UIColor(red: 247.0/255.0, green: 227.0/255.0, blue: 23.0/255.0, alpha: 1.0).cgColor //kakao color
        } else {
            shape.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
            shape.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        }

        let path = UIBezierPath()
        let meshMbr = mesh.mbr

        path.move(to: CGPoint(x: Double((polyGon.PointArr[0].x - meshMbr.minX) / ratio), y: Double((polyGon.PointArr[0].y - meshMbr.minY) / ratio)))
        for i in 1..<polyGon.PointArr.count {
            path.addLine(to: CGPoint(x: Double((polyGon.PointArr[i].x - meshMbr.minX) / ratio), y: Double((polyGon.PointArr[i].y - meshMbr.minY) / ratio)))
        }
        path.close()
        shape.path = path.cgPath
        
        
        //검색한 좌표를 빨간색 원으로 표시한다.
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: (x - meshMbr.minX) / ratio, y: (y - meshMbr.minY) / ratio), radius: CGFloat(3), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0

        view.layer.addSublayer(shapeLayer)
    }
}
