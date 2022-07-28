//
//  ViewController.swift
//  COVID19
//
//  Created by 임가영 on 2022/07/16.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicatorView.startAnimating()
        // 앱이 실행되고 뷰 컨트롤러가 표시될 때 시도별 코로나 현황 API를 호출하도록
        self.fetchCovidOverview(completionHandler: { [weak self] result in  // 순환참조 방지 weak self
            guard let self = self else { return }  // 일시적으로 self가 강한참조가 되도록
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            self.labelStackView.isHidden = false
            self.pieChartView.isHidden = false
            switch result {
            // 서버에서 응답받은 JSON 데이터를 매핑한 CityCovidOverview 객체가 콘솔에 출력
            case let .success(result):
                self.configureStackView(koreaCovidOverview: result.korea)
                let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configureChartView(covidOverviewList: covidOverviewList)
                
            case let .failure(error):
                debugPrint("error \(error)")
            }
        })
    }
    
    func makeCovidOverviewList(
        cityCovidOverview: CityCovidOverview
    ) -> [CovidOverview] {
        return [
            cityCovidOverview.seoul,
            cityCovidOverview.busan,
            cityCovidOverview.daegu,
            cityCovidOverview.incheon,
            cityCovidOverview.gwangju,
            cityCovidOverview.daejeon,
            cityCovidOverview.ulsan,
            cityCovidOverview.sejong,
            cityCovidOverview.gyeonggi,
            cityCovidOverview.chungbuk,
            cityCovidOverview.chungnam,
            cityCovidOverview.jeonbuk,
            cityCovidOverview.jeonnam,
            cityCovidOverview.gyeongbuk,
            cityCovidOverview.gyeongnam,
            cityCovidOverview.jeju
        ]
    }
    
    // 파이차트를 구성하는 메서드
    func configureChartView(covidOverviewList: [CovidOverview]) {
        self.pieChartView.delegate = self
        // 전달받은 CovidOverview 배열을 entries 객체로 매핑시켜주기
        let entries = covidOverviewList.compactMap { [weak self] overview -> PieChartDataEntry? in
            guard let self = self else { return nil }  // 일시적으로 강한참조
            return PieChartDataEntry( // 매핑하기
                value: self.removeFormatString(string: overview.newCase),  // Double 타입 넘겨줘야함
                label: overview.countryName,  // 도시이름 = 항목이름
                data: overview
            )
        }
        let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
        
        dataSet.sliceSpace = 1  // 항목 간 간격 1
        dataSet.entryLabelColor = .black  // 항목 이름 검정색
        dataSet.valueTextColor = .black  // 차트 안의 값도 검정색
        dataSet.xValuePosition = .outsideSlice  // 항목 이름이 차트안말고 바깥쪽 선으로 표시되도록
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3
        
        // 항목이 다양한 색으로 나오도록
        dataSet.colors = ChartColorTemplates.vordiplom() +
        ChartColorTemplates.joyful() +
        ChartColorTemplates.liberty() +
        ChartColorTemplates.pastel() +
        ChartColorTemplates.material()
        
        // 파이차트뷰에 데이터 할당
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        
        // 파이차트 회전해서 글씨 안겹치게 보이도록 하기
        self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 85)
    }
    
    // String -> Double
    func removeFormatString(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0  // nil 이면 0
    }
    
    func configureStackView(koreaCovidOverview: CovidOverview) {
        self.totalCaseLabel.text = "\(koreaCovidOverview.totalCase)명"
        self.newCaseLabel.text = "\(koreaCovidOverview.newCase)명"
    }
    
    // @escaping 클로저는 클로저가 함수로 탈출한다는 의미로
    // 함수에 인자로 클로저가 전달되지만 함수가 반환된 후에도 실행되는 것을 의미
    // 비동기 작업을 하는 경우 completionHandler 로 @escaping 클로저 사용함
    // 보통 네트워킹 작업은 비동기 작업,
    // completionHandler클로저는 fetchCovidOverview 함수가 반환된 후에 호출됨
    // 그 이유는 서버에서 데이터를 언제 응답시켜줄지 모르기 때문
    // @escaping 클로저로 정의하지 않는다면 서버에서 비동기로 데이터를 응답받기 전 함수가 종료돼서
    // 서버에 응답을 받아도 completionHandler가 호출되지 않음
    func fetchCovidOverview (
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
    ) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        let param = [
            "serviceKey": "xXoYSj1sbNOFE3tWgvkm86UA4ZQVRu7DK"
        ]
        
        // request 메서드를 이용해 API를 호출했다면 응답 데이터를 받을 수 있는 메서드(responseData)를 체이닝 해줘야 함
        AF.request(url, method: .get, parameters: param).responseData(completionHandler: { response in
            // 요청에 대한 응답 결과 response.result
            // 열거형으로 되어있어서 switch 문으로 접근
            switch response.result {
            // 요청 결과가 success 이면 연관값으로 서버에서 응답받은 데이터가 전달됨
            case let .success(data):
                // 응답 받은 JSON 데이터를 CityCovidOverview 객체에 매핑되도록
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CityCovidOverview.self, from: data)
                    completionHandler(.success(result))
                } catch { // 매핑에 실패한다면
                    completionHandler(.failure(error))
                }
            // 요청이 실패했을때
            case let .failure(error):
                completionHandler(.failure(error))
            }
            
        })
    }
}

extension ViewController: ChartViewDelegate {
    // 차트에서 항목을 선택하였을 때 호출되는 메서드
    // 엔트리 메서드 파라미터를 통해 선택된 항목이 저장되어 있는 데이터를 가져올 수 있음
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // 스토리보드에 있는 CovidDetailViewController를 인스턴스화
        guard let covidDetailViewController = self.storyboard?.instantiateViewController(identifier: "CovidDetailViewController") as? CovidDetailViewController else { return }
        guard let covidOverview = entry.data as? CovidOverview else { return }
        // 선택된 항목에 저장되어있는 데이터를 전달시켜줌
        covidDetailViewController.covidOverview = covidOverview
        // 항목을 누르면 covidDetailViewController로 push 되도록
        self.navigationController?.pushViewController(covidDetailViewController, animated: true)
     }
}
