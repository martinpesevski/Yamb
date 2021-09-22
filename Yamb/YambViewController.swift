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
    @IBOutlet var topStack: UIStackView!
    
    let columns: [Column] = [.rowNames, .down, .up, .free, .midOut, .outMid, .announce, .disannounce]
    
    lazy var dataSource: YambDataSource = {
        let data = YambDataSource(columns: columns)
        data.loadScores()
        
        return data;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yambCollectionView.register(YambCell.self, forCellWithReuseIdentifier: "numberCell")

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width/CGFloat(columns.count)) - 3, height: 45)
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        yambCollectionView.collectionViewLayout = flowLayout;
        yambCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
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
            if indexPath.section == 0 { message = "This shows the sum of the above column.\n\n If the sum is equal to or greater than 60, you will get 30 extra points"}
            else if indexPath.section == 1 { message = "This shows the result of the above column.\n\n It is calculated by subtracting the Min from the Max and multiplying the result by the number of Ones.\n\n If the result is equal to or greater than 60, you will get 30 extra points" }
            else if indexPath.section == 2 { message = "This shows the sum of the above column" }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .ColumnHeader:
            let alert = UIAlertController(title: nil, message: field.column.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .RowName:
            guard let description = field.row?.description else { return }
            let alert = UIAlertController(title: nil, message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func didSelect(_ diceRolls: [DiceRoll], indexPath: IndexPath?, hasStar: Bool) {
        guard let indexPath = indexPath else { return }
        dataSource.setScore(diceRolls: diceRolls, indexPath: indexPath, hasStar: hasStar)
        yambCollectionView.reloadData()
        totalScoreLabel.text = "Total: \(dataSource.totalScore)"
    }
    
    func didClear(indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        dataSource.clear(indexPath: indexPath)
        yambCollectionView.reloadData()
        totalScoreLabel.text = "Total: \(dataSource.totalScore)"
    }
    
    @IBAction func onNewGame(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to abandon the current game and start a new one?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.dataSource.resetScores()
            self.yambCollectionView.reloadData()
            self.totalScoreLabel.text = "Total: \(self.dataSource.totalScore)"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didDismiss() {
        if dataSource.isGameEnded {
            let alert = UIAlertController(title: "GAME OVER", message: "TOTAL SCORE: \(dataSource.totalScore)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "New game", style: .default, handler: { _ in
                self.dataSource.resetScores()
                self.yambCollectionView.reloadData()
                self.totalScoreLabel.text = "Total: \(self.dataSource.totalScore)"
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
