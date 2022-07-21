//
//  ViewController.swift
//  Calculator
//
//  Created by 임가영 on 2022/07/10.
//

import UIKit

enum Operation {
    case Add
    case Subtract
    case Divide
    case Multiply
    case unknown
}

class ViewController: UIViewController {

    @IBOutlet weak var numberOutputLabel: UILabel!
    
    // 계산기 버튼을 누를떄마다 numberouputlabel에 표시되는 숫자
    var displayNumber = ""
    // 이전 계산값 저장 프로퍼티, 첫번째 피연산자
    var firstOperand = ""
    // 새롭게 입력된 값을 저장하는 프로퍼티, 두번째 피연산자
    var secondOperand = ""
    // 결과값 저장 프로퍼티
    var result = ""
    // 현재 계산기에 어떤 연산자가 입력되었는지 알 수 있게 연산자를 저장하는 프로퍼티
    var currentOperation: Operation = .unknown
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapNumberButton(_ sender: UIButton) {
        // 선택한 버튼의 타이틀 값 가져오기
        // 옵셔널 값이라 가드문으로 옵셔널 바인딩
        guard let numberValue = sender.title(for: .normal) else { return }
        // 숫자는 9자리까지만 입력하도록 설정
        if self.displayNumber.count < 9 {
            self.displayNumber += numberValue
            self.numberOutputLabel.text = self.displayNumber
        }
    }
    
    @IBAction func tapClearButton(_ sender: UIButton) {
        self.displayNumber = ""
        self.firstOperand = ""
        self.secondOperand = ""
        self.result = ""
        self.currentOperation = .unknown
        self.numberOutputLabel.text = "0"
    }
    
    @IBAction func tapDotButton(_ sender: UIButton) {
        // 소수점 포함 9자리까지 표시하도록, 소수점이 포함되어있지 않았을 때 (소수점 1개만 가능하게)
        if self.displayNumber.count < 8, !self.displayNumber.contains(".") {
            // 비어있으면 0. 추가 비어있지 않으면 . 추가
            self.displayNumber += self.displayNumber.isEmpty ? "0." : "."
            self.numberOutputLabel.text = self.displayNumber
        }
    }
    
    @IBAction func tapDivideButton(_ sender: UIButton) {
        self.operation(.Divide)
    }
    
    @IBAction func tapMultiplyButton(_ sender: UIButton) {
        self.operation(.Multiply)
    }
    
    @IBAction func tapSubtractButton(_ sender: UIButton) {
        self.operation(.Subtract)
    }
    
    @IBAction func tapAddButton(_ sender: UIButton) {
        self.operation(.Add)
    }
    
    @IBAction func tapEqualButton(_ sender: UIButton) {
        self.operation(self.currentOperation)
    }
    
    // 계산 담당 함수
    func operation(_ operation: Operation){
        if self.currentOperation != .unknown {
            if !self.displayNumber.isEmpty {  // 입력된 두번째 피연산자가 있다면
                self.secondOperand = self.displayNumber  // 두번째 피연산자 대입
                self.displayNumber = ""  // 빈문자열로 초기화
                
                // 입력받은 것이 문자형이기 때문에 Double 형으로 전환
                guard let firstOperand = Double(self.firstOperand) else { return }
                guard let secondOperand = Double(self.secondOperand) else { return }
                
                
                // 연산시켜주는 코드
                switch self.currentOperation {
                case .Add:
                    self.result = "\(firstOperand + secondOperand)"
                case .Subtract:
                    self.result = "\(firstOperand - secondOperand)"
                case .Divide:
                    self.result = "\(firstOperand / secondOperand)"
                case .Multiply:
                    self.result = "\(firstOperand * secondOperand)"
                default:
                    break
                }
                // Double형 결과값을 정수형으로 변환
                if let result = Double(self.result), result.truncatingRemainder(dividingBy: 1) == 0 {
                    self.result = "\(Int(result))"
                }
                // 누적 연산
                self.firstOperand = self.result
                self.numberOutputLabel.text = self.result
            }
            self.currentOperation = operation
        } else {
            self.firstOperand = self.displayNumber // 첫번째 피연산자 대입
            self.currentOperation = operation // 연산자 대입
            self.displayNumber = "" // 이전 입력한 피연산자 초기화
        }
    }
}

