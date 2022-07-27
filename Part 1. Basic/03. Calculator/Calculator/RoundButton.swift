//
//  RoundButton.swift
//  Calculator
//
//  Created by 임가영 on 2022/07/10.
//

import UIKit

// @IBDesignable -> 변경된 설정값을 스토리보드상에 실시간으로 확인할 수 있도록 함
@IBDesignable
class RoundButton: UIButton {
    // @IBInspectable -> 스토리보드에서도 isRound 설정값을 변경할수 있도록 함
    @IBInspectable var isRound: Bool = false {  // 연산 프로퍼티
        didSet {
            if isRound {
                // 정사각형 -> 원, 정사각형아닌것들 -> 모서리 둥글게 변경
                self.layer.cornerRadius = self.frame.height / 2
            }
        }
    }
}
