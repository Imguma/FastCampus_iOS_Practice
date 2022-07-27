//
//  ViewController.swift
//  Weather
//
//  Created by 임가영 on 2022/07/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 날씨 가져오기 버튼 눌렀을 때 CurrentWeather API를 호출해서 현재 도시의 날씨정보 가져오기
    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)  // 버튼이 눌리면 키보드 사라지게!
        }
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name  // 도시 이름 표시
        if let weather = weatherInformation.weather.first { // 날씨 배열의 첫번째 요소가 상수에 대입되도록
            self.weatherDescriptionLabel.text = weather.description  // 현재 날씨 정보 표시
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"  // 절대온도 -> 섭씨온도
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃"
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 도시의 날씨 정보 가져오기
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=8b53d9aab71b96313d0c5c4881d66b7d") else { return }
        // URLSession에 해당 url을 넘겨줘서 API 호출
        let session = URLSession(configuration: .default) // 기본 세션
        // 서버로 데이터를 요청하고 응답받을 것임
        // dataTask가 API를 호출하고 서버에서 응답이 오면 completion 핸들러 클로저가 호출됨
        // 클로저의 data : 서버에서 응답받은 데이터
        // response : HTTP 헤더 및 상태 코드와 같은 응답 메타 데이터가 전달됨
        // error : 요청에 실패하면 에러 객체가 전달됨, 요청에 성공하면 nil 반환됨
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            // 응답받은 JSON 데이터 -> weather information 객체로 디코딩
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            // HTTP statusCode가 200번대 이면 응답 받은 JSON 데이터를 weatherInformation 객체로 디코딩하고
            // 200번대가 아니라면 에러일테니까 응답 받은 JSON 데이터를 errorMessage 객체로 디코딩
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                // try? -> 디코딩에 실패하면 에러를 던져줌
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                // 네트워크 작업은 별도의 스레드에서 진행되고 응답이 온다해도 자동으로 메인스레드에 돌아오지 않기 때문에
                // completion 핸들러 클로저에서 UI 작업을 한다면 메인 스레드에서 작업할 수 있도록
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false  // 날씨정보 스택뷰 표시하기
                    self?.configureView(weatherInformation: weatherInformation)  // 현재 날씨정보가 뷰에 표시되도록
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                debugPrint(errorMessage)
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
        }.resume()  // 작업 실행!
    }
}

