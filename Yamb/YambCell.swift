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
    
    var row: Row?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in make.center.equalToSuperview() }
        
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.label.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRow(_ row: Row) {
        self.row = row
    }
    
    func setupDiceRolls(_ diceRolls: [DiceRoll]) {
        guard let row = self.row else { return }
        
        self.textLabel.text = "\(row.calculate(diceRolls: diceRolls))"
        
        NSLog("row: \(row), dice rolls: \(diceRolls), result: \(self.textLabel.text ?? "")")
    }
}
