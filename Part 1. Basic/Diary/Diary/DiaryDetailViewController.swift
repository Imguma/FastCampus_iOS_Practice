//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 임가영 on 2022/07/14.
//

import UIKit

class DiaryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    var starButton: UIBarButtonItem?
    
    // 일기장 리스트 화면에서 전달받을 프로퍼티 선언
    var diary: Diary?
    var indexPath: IndexPath?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()  // 일기장 리스트 화면에서 일기장을 선택했을 때 상세화면이 나타남
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
    }
    
    // 프로퍼티를 통해 전달받은 diary 객체를 view에 초기화!
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title  // 제목
        self.contentsTextView.text = diary.contents  // 내용
        self.dateLabel.text = self.dateToString(date: diary.date)  // 날짜
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    // diary인스턴스에 있는 date 프로퍼티는 Date타입이므로 dateFormater를 이용해 문자열로 변환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // 수정된 diary 객체를 전달받아서 view에 업데이트 되도록 구현
    @objc func editDiaryNotification(_ notification: Notification) {
        // editDiaryNotification 메서드에서 post해서 보낸 수정된 다이어리를 가져오는 코드
        guard let diary = notification.object as? Diary else { return }
        self.diary = diary
        self.configureView()
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = self.diary else { return }
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
            self.configureView()
        }
    }
    // 수정버튼을 눌렀을 때
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        // editDiaryNotification을 관찰하는 옵저버 추가
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)), // notification을 탐지하고 있다가 이벤트가 발생하면 셀렉터에 정의된 함수가 호출됨
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        // 수정버튼이 눌렸을 때 일기 작성 화면으로 이동!
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 삭제버튼을 눌렀을 때
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.diary?.uuidString else { return }
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString,
            userInfo: nil
        )
        // 삭제버튼이 눌렸을 때 이전화면으로 이동하도록
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapStarButton() {
        guard let isStar = self.diary?.isStar else { return }
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object: [
                "diary": self.diary,
                "isStar": self.diary?.isStar ?? false,
                "uuidString": diary?.uuidString
            ],
            userInfo: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
