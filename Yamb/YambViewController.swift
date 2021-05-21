//
//  ViewController.swift
//  Yamb
//
//  Created by Martin Peshevski on 31.12.20.
//

import UIKit

class YambViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DiceSelectionDelegate {

    @IBOutlet var totalScoreLabel: UILabel!
    @IBOutlet var yambCollectionView: UICollectionView!
    
    let columns: [Column] = [.rowNames, .down, .up, .free, .midOut, .outMid, .announce, .disannounce]
    
    lazy var dataSource = YambDataSource(columns: columns)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yambCollectionView.register(YambCell.self, forCellWithReuseIdentifier: "numberCell")

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width/CGFloat(columns.count)) - 3, height: 45)
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        yambCollectionView.collectionViewLayout = flowLayout;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.fieldsDict[section]?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.fieldsDict.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "numberCell", for: indexPath) as? YambCell ?? YambCell(frame: .zero)
        if let field = dataSource.fieldsDict[indexPath.section]?[indexPath.item] {
            cell.setup(field: field)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let field = dataSource.fieldFor(indexPath: indexPath) else { return }
        
        switch field.type {
        case .Yamb:
            if !field.isEnabled { return }
            if field.row?.section == .middle || field.row == .full {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let diceSelection = storyboard.instantiateViewController(withIdentifier: "diceSelection") as? MinMaxDiceSelectionViewController else { return }
                diceSelection.field = field
                diceSelection.delegate = self
                diceSelection.shouldShowClear = field == dataSource.lastPlayedField
                self.present(diceSelection, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let diceSelection = storyboard.instantiateViewController(withIdentifier: "topBottomSelection") as? TopBottomDiceSelectionViewController else { return }
                diceSelection.field = field
                diceSelection.delegate = self
                diceSelection.shouldShowClear = field == dataSource.lastPlayedField
                self.present(diceSelection, animated: true)
            }
        case .Result:
            var message = ""
            if indexPath.section == 0 { message = "This shows the sum of the above column. If the sum is equal to or greater than 60, you will get 30 extra points"}
            else if indexPath.section == 1 { message = "This shows the result of the above column. It is calculated by subtracting the Min from the Max and multiplying the result by the number of Ones. If the result is equal to or greater than 60, you will get 30 extra points" }
            else if indexPath.section == 2 { message = "This shows the sum of the above column" }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .ColumnHeader:
            let alert = UIAlertController(title: nil, message: field.column.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .RowName:
            let alert = UIAlertController(title: nil, message: field.row?.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func didSelect(_ diceRolls: [DiceRoll], indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        dataSource.setScore(diceRolls: diceRolls, indexPath: indexPath)
        yambCollectionView.reloadData()
        totalScoreLabel.text = "Total: \(dataSource.totalScore)"
    }
    
    func didClear(indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        dataSource.clear(indexPath: indexPath)
        yambCollectionView.reloadData()
        totalScoreLabel.text = "Total: \(dataSource.totalScore)"
    }
    
    func didDismiss() {
        if dataSource.isGameEnded {
            let alert = UIAlertController(title: "GAME OVER", message: "TOTAL SCORE: \(dataSource.totalScore)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "New game", style: .default, handler: { _ in
                self.dataSource = YambDataSource(columns: self.columns)
                self.yambCollectionView.reloadData()
                self.totalScoreLabel.text = "Total: \(self.dataSource.totalScore)"
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
