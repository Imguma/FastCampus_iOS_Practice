//
//  ViewController.swift
//  pomodoro
//
//  Created by 임가영 on 2022/07/15.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    var duration = 60  // 타이머에 설정된 시간을 초로 저장하는 프로퍼티
    var timerStatus: TimerStatus = .end  // 타이머 상태 프로퍼티
    var timer: DispatchSourceTimer?
    var currentSeconds = 0 // 현재 카운트다운되고 있는 시간을 초로 저장하는 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    func setTimerInfoViewVisible(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    func configureToggleButton() {
        // 버튼 초기상태가 normal이면 버튼 타이틀이 시작으로 변경
        // 버튼 초기상태가 selected이면 일시정지로 변경
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    // 타이머를 설정하고 시작하기
    func startTimer() {
        if self.timer == nil {
            // 타이머 인스턴스 생성
            // 어떤 스레드 큐에서 반복동작 할 것인지 설정
            // 타이머가 돌때마다 UI관련 작업을 해주어야 하므로 main
            // main스레드는 iOS에서 오직 한개만 존재하는데 일반적으로 작성하는 대부분의 코드는 메인스레드에서 실행됨(UI와 관련된 코드는 반드시 메인스레드에서 작성되어야함)
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            // 어떤 주기로 타이머를 실행할건지, 타이머가 시작되면 즉시 실행, 1초마다 반복
            // .now() + 3 -> 3초후 실행
            self.timer?.schedule(deadline: .now(), repeating: 1)
            // 타이머가 동작할때마다(1초마다) 핸들러의 클로저 함수 호출됨
            self.timer?.setEventHandler(handler: { [ weak self ] in
                guard let self = self else { return }  // strong 타입
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                // 2자리 수 표현, 콜론으로 구분
                self.timerLabel.text =  String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                // 카운트다운 될때마다 progress 게이지가 줄어듦, 프로그레스는 Float 타입!
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                // 애니메이션 구현
                UIView.animate(withDuration: 0.5, delay: 0, animations: { // delay: 몇초뒤에 애니메이션 동작할건지
                    // 뷰의 외형 변경, pi -> 180도
                    // CGAffineTransform 구조체로 뷰의 프레임을 계산하지 않고 2D 그래픽을 그릴 수 있음
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2) // 360도 회전
                })
                
                if self.currentSeconds <= 0 {
                    // 타이머 종료
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()  // 타이머 재시작!!!
        }
    }
    
    // 타이머 종료 메서드
    func stopTimer() {
        // 타이머를 suspend메서드를 호출해 일시정지하면 아직 수행해야할 작업이 있음을 의미하기 때문에
        // suspend된 타이머에 nil을 대입하면 런타임 에러 발생! resume() 메서드로 해결하기!!
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false  // 취소버튼 비활성화
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity  // 이미지뷰가 원상태로 돌아오도록
        })
        self.toggleButton.isSelected = false // 일시정지 -> 시작
        self.timer?.cancel()  // 타이머 종료해주기
        self.timer = nil      // 타이머 메모리에서 해제시켜주기(필수!!)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        // countDownDuration은 datePicker에서 선택한 타이머 시간이 몇초인지 알려줌!
        // ex) 2분 -> 120초
        self.duration = Int(self.datePicker.countDownDuration)
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start  // 시작 상태
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggleButton.isSelected = true  // 시작 -> 일시정지
            self.cancelButton.isEnabled = true // 취소버튼 활성화
            self.startTimer() // 타이머 시작!!!
        
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false // 일시정지 -> 시작
            self.timer?.suspend()  // 타이머 일시정지!!!
        
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true // 시작 -> 일시정지
            self.timer?.resume()  // 타이머 재시작!!!
        
        default:
            break
        }
    }
}
