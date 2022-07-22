//
//  DiaryCell.swift
//  Diary
//
//  Created by 임가영 on 2022/07/14.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // 이 생성자는 UIView가 Xib(?) 나 스토리보드에서 생성될 때
    // 이 생성자를 통해 객체가 생성됨
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // cell 테두리
        self.contentView.layer.cornerRadius = 3.0  // 테두리 둥글게
        self.contentView.layer.borderWidth = 1.0   // 테두리 너비
        self.contentView.layer.borderColor = UIColor.black.cgColor  // 검정색 테두리
    }
}
