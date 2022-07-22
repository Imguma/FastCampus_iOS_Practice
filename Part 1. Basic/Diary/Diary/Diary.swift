//
//  Diary.swift
//  Diary
//
//  Created by 임가영 on 2022/07/14.
//

import Foundation

struct Diary {
    var uuidString: String // 일기를 생성할때마다 일기를 특정할 수 있는 고유 식별 id
    var title: String    // 일기 제목
    var contents: String // 일기 내용
    var date: Date       // 일기 날짜
    var isStar: Bool     // 즐겨찾기 여부
}
