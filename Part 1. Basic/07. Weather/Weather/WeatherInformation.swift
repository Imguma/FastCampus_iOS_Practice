//
//  WeatherInformation.swift
//  Weather
//
//  Created by 임가영 on 2022/07/16.
//

import Foundation

// Codable 프로토콜
// 자신을 변환하거나 외부 표현(JSON같은)으로 변환할 수 있는 타입을 의미
// JSON 디코딩, 인코딩이 모두 가능함!!
struct WeatherInformation: Codable {
    let weather: [Weather]
    let temp: Temp
    let name: String
    
    // String 타입 열거형
    enum CodingKeys: String, CodingKey {
        case weather
        case temp = "main"
        case name
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Temp: Codable {
    let temp: Double
    let feelsLike: Double
    let minTemp: Double
    let maxTemp: Double
    
    // 프로퍼티 이름이 달라도 매핑될 수 있게 CodingKey 프로토콜 채택
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
    }
}
