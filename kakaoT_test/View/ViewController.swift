//
//  ViewController.swift
//  kakaoT_test
//
//  Created by Jang Dong Min on 2020/01/30.
//  Copyright © 2020 Jang Dong Min. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var XTextField: UITextField!
    @IBOutlet weak var YTextField: UITextField!
    @IBOutlet weak var VerifyView: UIView!
    @IBOutlet weak var ResultLabel: UILabel!
    @IBOutlet weak var VerifyLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        zone 검색 속도를 높이기 위해서
//        파일읽기&데이터 파싱할때, 모든 zone과 polygon의 MBR 값을 만들었습니다. (zone의 MBR은 포함된 polygon을 이용하여 만들었습니다.)
//        검색순서는 mesh MBR -> zone MBR -> polygon MBR -> polygon. (입력한 x, y 값이 각각의 MBR안에 있을 경우 다음으로 진행)
//
//        polygon안에 x, y값이 있는지에 대한 판별은,
//
//        다각형 안에 일정 점에서 밖으로 나가는 선을 그어
//        교차되는 점의 갯수가 홀수이면 안에 있고,
//        짝수이면 밖에 있다고 판정.
//
//        입력한 x, y 좌표가 polygon 안에 있을 경우 해당 zone 출력.
//
        
        //test.dat 파일 읽기 & 데이터 파싱.
        if !DataManager.sharedInstance.readDatFile("test") {
             print("file open fail")
        } 
    }
    
    @IBAction func SearchButtonClick(_ sender: Any) {
//
//        검색하기 버튼 눌렀을때,
//        DataManager.sharedInstance.searchZone.searching 에 x, y 값을 넘겨줍니다.
//        검색시간을 측정하기 위해, 경과시간을 log로 출력 하였습니다. (1회 검색, 측정 시간 약 0.000326037407 seconds)
//        결과는 log와 앱 화면에 출력됩니다.
//
        if XTextField.text == "" || YTextField.text == "" {
            let result = "X, Y 좌표를 입력해주세요."
            print(result)
            ResultLabel.text = result
            elapsedTimeLabel.text = ""
        } else {
            if let x = Int(XTextField.text!) {
                if let y = Int(YTextField.text!) {
                    
                    //MapCoverage 크기를 벗어났을때 예외 처리.
                    if DataManager.sharedInstance.MapCoverage.maxX + 1 > x &&
                        DataManager.sharedInstance.MapCoverage.maxY + 1 > y {
                        
                        let startTime = Date()
                        
                        if let zoneName = DataManager.sharedInstance.searchZone.searching(x: x, y: y) {
                            print(zoneName)
                            ResultLabel.text = zoneName
                        }

                        let endTime = Date().timeIntervalSince(startTime)
                        elapsedTimeLabel.text = "경과시간: \(String(format: "%.12f", endTime)) seconds"
                        print("\n경과시간: \(String(format: "%.12f", endTime)) seconds")
                        
                    } else {
                        let result = "X = (\( DataManager.sharedInstance.MapCoverage.minX)~\( DataManager.sharedInstance.MapCoverage.maxX))\nY = (\( DataManager.sharedInstance.MapCoverage.minY)~\( DataManager.sharedInstance.MapCoverage.maxY))\n사이의 값을 입력해 주세요."
                        print(result)
                        ResultLabel.text = result
                        elapsedTimeLabel.text = ""
                    }
                } else {
                    elapsedTimeLabel.text = ""
                    print("Int형 변환 에러")
                }
            } else {
                elapsedTimeLabel.text = ""
                print("Int형 변환 에러")
            }
        }
        
        XTextField.resignFirstResponder()
        YTextField.resignFirstResponder()
        VerifyLabel.text = ""
        VerifyView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    @IBAction func VerifyButtonClick(_ sender: Any) {
//
//        결과로 출력된 zone을 검증하기 위해 만들었습니다. (입력한 x, y가 해당 zone 안에 있는지 확인하기 위해)
//
//        입력한 x, y 값에 매칭된 zone 또는 polygon을 그립니다.
//        입력한 x, y 좌표에 빨간색 원을 표시한다. (매칭된 zone을 볼 수가 있습니다.)
//
//        계산식 :
//        polygon의 point.x, point.y 값에
//        (point.x - meshMBR.minX)  / 100, (point.y - meshMBR.maxY) / 100
//        (100은 결과 값을 축소시키기 위해서)
//
//        동일한 좌표계에서 출력하기 위해,
//        입력한 X, Y 값에도
//        (X - meshMBR.minX) / 100, (Y - meshMBR.maxY) / 100
//
//        verify는, searching 작업이 선행되어야 합니다.
//
//        type = 0은 polygon 그리기
//        type = 1은 zone 그리기
//

        if XTextField.text == "" || YTextField.text == "" {
            let result = "X, Y 좌표를 입력해주세요."
            print(result)
            ResultLabel.text = result
        } else {
            VerifyView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

            if let x = Int(XTextField.text!) {
                if let y = Int(YTextField.text!) {
                    DataManager.sharedInstance.verifyZone.verify(x: x, y: y, type: 1, view: VerifyView)
                     
                    VerifyLabel.text = "검증결과 : MeshIndex = \(DataManager.sharedInstance.selectMeshIndex) (zone_\(DataManager.sharedInstance.selectMeshIndex/3)_\(DataManager.sharedInstance.selectMeshIndex%3)), ZoneIndex = \(DataManager.sharedInstance.selectZoneIndex), PolygonIndex = \(DataManager.sharedInstance.selectPolygonIndex)"
                } else {
                    print("Int형 변환 에러")
                }
            } else {
                print("Int형 변환 에러")
            }
        }
        
        XTextField.resignFirstResponder()
        YTextField.resignFirstResponder()
    }
}
 
extension ViewController: UITextFieldDelegate {
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let textFieldText = textField.text,
             let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                 return false
         }
         let substringToReplace = textFieldText[rangeOfTextToReplace]
         let count = textFieldText.count - substringToReplace.count + string.count
         return count <= 5
     }
}
 
