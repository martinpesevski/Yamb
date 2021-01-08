//
//  YambCell.swift
//  Yamb
//
//  Created by Martin Peshevski on 5.1.21.
//

import UIKit
import SnapKit

class YambCell: UICollectionViewCell {
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in make.center.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(field: Field) {
        switch field.type {
        case .Yamb:
            if let score = field.score {
                textLabel.text = "\(score)"
            } else {
                textLabel.text = ""
            }

            backgroundColor = field.isEnabled ? .systemGray5 : .systemBackground
            layer.cornerRadius = 5
            layer.borderWidth = 1
            layer.borderColor = UIColor.label.cgColor
        case .Result:
            backgroundColor = .systemBackground
            textLabel.text = "\(field.score ?? 0)"
            layer.borderWidth = 0
        case .ColumnHeader:
            backgroundColor = .systemBackground
            textLabel.text = field.column.headerTitle
            layer.borderWidth = 0
        case .RowName:
            backgroundColor = .systemBackground
            textLabel.text = field.row?.title
            layer.borderWidth = 0
        }
    }
}
