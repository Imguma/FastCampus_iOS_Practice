//
//  ViewController.swift
//  Diary
//
//  Created by 임가영 on 2022/07/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Diary 타입 배열 선언 및 초기화
    private var diaryList = [Diary]() { // 프로퍼티 옵저버
        didSet { // diaryList 배열에 일기가 추가되거나 변경이 일어날 때마다 userDefaults에 저장됨
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        // Observer Pattern(옵저버)이란 관찰 중인 객체에서 발생하는 이벤트를
        // 여러 다른 객체에 알리는 메커니즘을 정의할 수 있는 디자인 패턴
        NotificationCenter.default.addObserver( // 옵저버 추가
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: Notification.Name("deleteDiary"),
            object: nil
        )
    }
    
    // diaryList 배열에 추가된 일기를 CollectionView에 표시되도록 구현
    
    // CollectionView 속성 정의 함수
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        // CollectionView에 표시되는 contents의 좌우 위아래에 간격 10만큼
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return } // 전달받은 diary 객체 가져오기
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
        self.diaryList[index] = diary  // 해당 배열 요소를 수정된 diary 객체로 변경
        self.diaryList = self.diaryList.sorted(by: {  // 날짜가 수정될수도 있으니 최신순으로 정렬
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData() // collectionView cell에도 수정된 일기 내용으로 변경됨
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList[index].isStar = isStar
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        // 전달받은 index에 있는 배열 요소 삭제
        self.diaryList.remove(at: index)
        // 전달받은 index를 넘겨줘서 collectionView에 일기가 삭제되도록
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    // 일기 작성의 화면 이동은 세그웨이를 통해서 이동하기 때문에 prepare 메서드 재정의
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
    
    // 일기들을 userDefaults에 딕셔너리 배열 형태로 저장하고자함
    private func saveDiaryList() {
        let date = self.diaryList.map {
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
    }
    
    // userDefaults에 저장된 값을 불러오는 메서드
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard
        // object 메서드는 Any 타입으로 리턴되기 때문에 딕셔너리 배열 형태로 타입캐스팅!
        // 타입캐스팅에 실패하면 nil이 될 수 있으니 guard 문 옵셔널 바인딩
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }
        // 일기를 불러올때 최신순으로 정렬
        self.diaryList = self.diaryList.sorted(by: {
            // 배열의 왼쪽과 오른쪽 날짜를 iteration을 돌면서 비교하면서 최신순으로 정렬
            $0.date.compare($1.date) == .orderedDescending // 내림차순 정렬
        })
    }
    
    // diary인스턴스에 있는 date 프로퍼티는 Date타입이므로 dateFormater를 이용해 문자열로 변환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// CollectionView 에서 DataSource는 CollectionView로 보여주는 contents를 관리하는 객체
extension ViewController: UICollectionViewDataSource {
    // 무조건 구현해야하는 필수 메서드
    // 지정된 섹션에 표시할 cell의 갯수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    // 무조건 구현해야하는 필수 메서드
    // CollectionView의 지정된 위치에 표시할 cell을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeueReusableCell 메서드는 withReuseIdentifier 파라미터로 전달받은 재사용 식별자를 통해
        // 재사용 가능한 CollectionViewCell을 찾고 이를 반환해줌
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        // DiaryCell 로 다운캐스팅, 실패시 빈 UICollectionViewCell이 반환되도록
        
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    // cell의 사이즈 설정 메서드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // cell이 행에 2개씩 나오도록
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

extension ViewController: UICollectionViewDelegate {
    // 특정 cell이 선택되었음을 알리는 메서드
    // + DiaryDetailViewController가 push되도록 구현
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 스토리보드에 있는 뷰컨트롤러를 인스턴스화 해줌
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        // 선택한 일기가 뭔지 diary 상수에 대입
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        // 일기장 상세 화면이 push 되도록
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController: WriteDiaryViewDelegate {
    // 일기가 작성이 되면 didSelectRegister 메서드 파라미터를 통해 작성된 일기의 내용이 담겨져 있는 다이어리 객체가 전달됨
    func didSelectRegister(diary: Diary) {
        // 일기 작성에서 일기가 등록될때마다 diary 배열에 등록된 일기가 추가됨!
        self.diaryList.append(diary)
        // 일기를 등록할때 날짜가 최신순으로 정렬되도록
        self.diaryList = self.diaryList.sorted(by: {
            // 배열의 왼쪽과 오른쪽 날짜를 iteration을 돌면서 비교하면서 최신순으로 정렬
            $0.date.compare($1.date) == .orderedDescending // 내림차순 정렬
        })
        // 등록한 일기기 collectionView에 추가됨!
        self.collectionView.reloadData()
    }
}
