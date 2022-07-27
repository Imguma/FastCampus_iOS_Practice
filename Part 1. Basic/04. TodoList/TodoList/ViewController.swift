//
//  ViewController.swift
//  TodoList
//
//  Created by 임가영 on 2022/07/10.
//

import UIKit

class ViewController: UIViewController {
    
    // strong -> weak가 되어버리면 왼쪽 네비게이션 아이템을 done으로 바꿨을 때 edit버튼이 메모리에서 해제되어 재사용할 수 없게 되기 때문에
    @IBOutlet var editButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    var doneButton: UIBarButtonItem?
    // 할일 저장해주는 배열
    var tasks = [Task]() {
        didSet { // 프로퍼티 옵저버
            self.saveTasks() // tasks배열에 할일이 추가될때마다 UserDefaults에 할일이 저장됨(호출)
                             
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIBarButtonItem 생성
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.tableView.dataSource = self
        self.tableView.delegate = self // UITableViewDelegate 채택해야함
        self.loadTasks() // 저장된 할일 불러오기
    }
    
    // done 버튼 선택됐을 때 호출되는 메서드
    // selector 타입으로 전달할 메서드를 작성할때 반드시 @objc 키워드 사용
    @objc func doneButtonTap() {
        // done -> edit 변경, tableView도 편집모드에서 빠져나오도록
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        // edit버튼 눌렀을 때 tableView가 편집모드로 전환되도록
        // tableView가 비어있으면 편집모드로 들어갈 필요가 없으니 tasks 배열이 비어있지 않을 때만 편집모드로 전환되도록 방어코드 작성
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in // 사용자가 alert버튼을 눌렀을 때 실행해야하는 행동 정의
            guard let title = alert.textFields?[0].text else { return } // 등록버튼을 눌렀을 때 textField에 입력된 값 가져오기
            let task = Task(title: title, done: false) // task 구제체를 인스턴스화
            self?.tasks.append(task) // tasks 배열에 할일 추가
            self?.tableView.reloadData() // tasks 배열에 할일이 추가될 때 마다 tableView를 갱신해서 추가한 할일이 보이도록!
            
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        // addAction 함수 호출해서 UIButton 넣어주기
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        // alert에 텍스트 필드 추가
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요."
        } )
        // add 버튼 눌렀을 때 alert 실행되도록
        self.present(alert, animated: true, completion: nil)
    }
    func saveTasks() {
        let data = self.tasks.map { // 배열요소들을 딕셔너리형태로 매핑
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        // UserDefaults
        // 런타임 환경에서 동작
        // 앱이 실행되는 동안 기본 저장소에 접근해 데이터를 기록하고 가져오는 역할을 하는 인터페이스
        // key value 쌍으로 저장되고 싱글톤 패턴으로 설계되어 앱 전체에 단 하나의 인스턴스만 존재하게 됨
        let userDefaults = UserDefaults.standard // UserDefaults에 접근할 수 있도록(싱글톤이니 하나만 존재)
        userDefaults.set(data, forKey: "tasks") // UserDefaults에 할일들이 저장됨
    }
    // UserDefaults에 저장된 할일을 load하는 함수
    func loadTasks() {
        let userDefaults = UserDefaults.standard // UserDefaults에 접근할 수 있도록
        // 저장된 데이터 load
        // object 메서드는 Any타입으로 리턴되기 때문에 데이터를 딕셔너리 형태로 저장했으니 딕셔너리 배열 형태로 타입캐스팅
        // 타입캐스팅에 실패하면 nil이 될 수 있으니 가드문
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        // load된 데이터를 다시 tasks에 매핑
        self.tasks = data.compactMap {
            // 딕셔너리의 value가 Any 타입이기 때문에 String으로 변환
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            // Task타입이 되도록 인스턴스화
            return Task(title: title, done: done)
        }
    }
}

// UITableViewDataSource 프로토콜을 채택하게 되면 아래의 두 함수는 무조건 구현해줘야 함. (나머지 함수는 옵셔널이라 상관 없음)
extension ViewController: UITableViewDataSource {
    // 각 세션에 표시할 행의 개수를 묻는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return self.tasks.count
    }
    
    // 특정 섹션의 n번째 row를 그리는데 필요한 cell을 반환하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeueReusableCell 메서드를 이용해 스토리보드에 정의한 cell 가져오기
        // dequeueReusableCell 메서드는 지정된 재사용 식별자(withIdentifier)에 대한, 재사용 가능한 tableView cell 객체를 반환하고 이를 tableView에 추가
        // indexPath 위치에 해당 cell을 재사용하기 위해 indexPath를 넘겨줌
        // dequeueReusableCell 메서드는 메모리 낭비 방지를 위해 큐를 사용해 cell을 재사용함!
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done { // true이면 체크박스 표시
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        // 가져온 cell을 리턴하게 되면 스토리보드에 구현된 cell이 TableView에 표시됨
        return cell
    }
    
    // 편집모드에서 삭제버튼 눌렀을 때 삭제버튼이 눌러진 cell이 어떤 cell인지 알려주는 메서드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row) // 할일 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic) // 삭제된 cell의 indexPath 정보를 넘겨줘서 tableView에도 할일이 삭제되도록
        if self.tasks.isEmpty { // 모든 cell이 삭제되면
            self.doneButtonTap() // 편집모드를 빠져나오도록
        }
    }
    // 행이 다른 위치로 이동하면 sourceIndexPath 파라미터를 통해 원래 있었던 위치를 알려주고
    // destinationIndexPath 파라미터를 통해 어디로 이동했는지 알려줌
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       // tableView cell이 재정렬되면 할일을 저장하는 배열도 재정렬 되도록
        var tasks = self.tasks  // 배열 가져오기
        let task = tasks[sourceIndexPath.row] //배열의 요소에 접근
        tasks.remove(at: sourceIndexPath.row) // 원래의위치에 있던 할일 삭제
        tasks.insert(task, at: destinationIndexPath.row)  // 할일 넘겨주고(task) 이동한 위치(destinationIndexPath.row) 넘겨줌
        self.tasks = tasks  //재정렬된 배열 넘겨주어 할일 배열도 재정렬!
    }
}

extension ViewController: UITableViewDelegate {
    // cell을 선택했을 때 어떤 cell을 선택했는지 알려주는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row] // 배열요소에 접근
        task.done = !task.done // 반대가 되도록!
        self.tasks[indexPath.row] = task // 변경된 task를 원래 배열요소에 덮어씌워줌
        self.tableView.reloadRows(at: [indexPath], with: .automatic) // 선택된 cell만 reload
    }
}
