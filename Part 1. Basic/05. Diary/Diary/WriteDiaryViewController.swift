//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 임가영 on 2022/07/14.
//

import UIKit

enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary) // 연관값
}

protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    // 날짜 선택
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? // datePicker에서 선택된 date 저장 프로퍼티
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new // diaryEditorMode 를 저장하는 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        // 제목, 내용, 날짜가 모두 입력되어야만 등록할 수 있도록 처음엔 버튼 비활성화
        self.confirmButton.isEnabled = false
    }
    
    private func configureEditMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
        }
    }
    
    // diary인스턴스에 있는 date 프로퍼티는 Date타입이므로 dateFormater를 이용해 문자열로 변환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // 테두리 생성 함수
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 190/225, green: 190/225, blue: 190/225, alpha: 1.0)
        // rgb값이 0.0~1.0 사이이므로 /나눠줘야함
        // alpha -> 투명도(0.0~1.0), 0.0에 가까울수록 투명해짐
        
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5  // 테두리 너비
        self.contentsTextView.layer.cornerRadius = 5.0 // 모서리 둥글게
    }
    
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date  // 날짜만 나오게 설정
        self.datePicker.preferredDatePickerStyle = .wheels
        // addTarget 메서드에는 UIController 객체가 이벤트에 응답하는 방식을 설정해주는 메서드
        // 첫번째 파라미터: 타겟 설정
        // 두번째 파라미터: 이벤트가 발생했을때 그에 응답하여 호출될 메서드를 셀렉터로 넘겨줌
        // 세번째 파라미터: 어떤 이벤트가 일어났을 때 action에 정의한 메서드를 호출할건지 설정
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged) // .valueChanged -> 값이 변경될 때
        self.datePicker.locale = Locale(identifier: "ko-KR")  //한국어 표현
        // 텍스트필드를 선택했을때 키보드가 아닌 datePicker가 표시됨
        self.dateTextField.inputView = self.datePicker
    }
    
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    // 일기를 다 작성하고 등록버튼을 눌렀을 때 Diary 객체를 생성하고
    // delegate에 정의한 didSelectRegister 메서드를 호출해서 메서드 파라미터에 생성된 Diary 객체를 전달
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        // 수정된 내용을 전달하는 NotificationCenter 구현
        // NotificationCenter는 등록된 이벤트가 발생하면 해당 이벤트들에 대한 행동을 취하는 것
        // 한마디로 앱 내에서 아무데서나 메세지를 던지면 아무데서나 이메세지를 받을수 있게 하는 것
        // 이벤트는 post 메서드를 이용해서 이벤트를 전송하고
        // 이벤트를 받으려면 옵저버를 등록해서 post한 이벤트를 전달 받을 수 있다.
        switch self.diaryEditorMode {
        case .new: // 일기 등록 행위!
            let diary = Diary(
                uuidString: UUID().uuidString, // 일기를 생성할때마다 고유한 id값 생성됨
                title: title,
                contents: contents,
                date: date,
                isStar: false
            )  // 즐겨찾기된 상태가 아니라 false
            self.delegate?.didSelectRegister(diary: diary)
            
        case let .edit(indexPath, diary): // 수정 모드
            let diary = Diary(
                uuidString: diary.uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: diary.isStar
            )
            // 수정된 다이어리 객체 전달
            NotificationCenter.default.post(
                // notification이름 가지고 옵저버에서 설정한 이름에
                // notification 이벤트가 발생하였는지 관찰하게 됨
                name: NSNotification.Name("editDiary"),
                object: diary,  // 전달할 객체 써주기
                userInfo: nil
            )
        }
        // 일기장 화면으로 변환
        self.navigationController?.popViewController(animated: true)
    }
    
    // 셀렉터 안에 넣어줄 메서드 정의
    @objc private func datePickerValueDidChange(_ dataPicker: UIDatePicker) {
        // 날짜와 텍스트를 변환해주는 역할(date타입을 사람이 읽을수 있는 문자열 형태로 변환 반대로 날짜형태의 문자열에서 date타입으로 변환하는 역할)
        let formater = DateFormatter()
        formater.dateFormat = "yyyy년 MM월 dd일(EEEEE)" // 어떤 형태의 문자열로 변경할건지
        formater.locale = Locale(identifier: "ko_KR") // 한국어 표현
        self.diaryDate = datePicker.date // datePicker에서 선택한 date 저장
        // date를 formater에 지정한 문자열로 변경해 dateTextField 표시되게 해줌
        self.dateTextField.text = formater.string(from: datePicker.date)
        // 날짜가 변경될때마다 editingChanged 액션을 발생시켜 dateTextFieldDidChange메서드가 호출됨
        self.dateTextField.sendActions(for: .editingChanged)
        
    }
    
    // 제목 텍스트 필드에 텍스트가 입력될때마다 호출되는 메서드 정의
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()  // 등록 버튼 활성화 여부 판단 메서드 호출
    }
    
    // 날짜가 변경될때마다 호출되는 메서드 정의
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()  // 등록 버튼 활성화 여부 판단 메서드 호출
    }
    
    // 유저가 화면을 터치하면 호출됨
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 빈화면을 누르면 키보드나 datePicker가 사라짐
    }
    
    // 등록 버튼 활성화 여부 판단 메서드
    private func validateInputField() {
        // 모든 InputField가 비어있지 않으면 등록 버튼이 활성화 됨!
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
}

extension WriteDiaryViewController: UITextViewDelegate{
    // textView에 텍스트가 입력될때마다 호출되는 메서드
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()  // 등록 버튼 활성화 여부 판단 메서드 호출
    }
}
