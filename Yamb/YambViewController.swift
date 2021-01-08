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
    
    let columns: [Column] = [.down, .up, .free, .midOut, .outMid, .announce, .disannounce]
    
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
        guard let field = dataSource.fieldFor(indexPath: indexPath), field.isEnabled else { return }
        
        switch field.type {
        case .Yamb:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let diceSelection = storyboard.instantiateViewController(withIdentifier: "diceSelection") as? DiceSelectionViewController else { return }
            diceSelection.indexPath = indexPath
            diceSelection.delegate = self
            self.present(diceSelection, animated: true)
        case .Result: return
        case .ColumnHeader: return
        }
    }
    
    func didSelect(_ diceRolls: [DiceRoll], indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        dataSource.setScore(diceRolls: diceRolls, indexPath: indexPath)
        yambCollectionView.reloadData()
        totalScoreLabel.text = "Total: \(dataSource.totalScore)"
    }
}
