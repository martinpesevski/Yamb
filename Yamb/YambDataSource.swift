//
//  YambDataSource.swift
//  Yamb
//
//  Created by Martin Peshevski on 7.1.21.
//

import UIKit

let kScoreDictKey = "yambSavedScore"

enum FieldType: Int, Codable {
    case Yamb
    case Result
    case ColumnHeader
    case RowName
}

class YambDataSource {
    let columns: [Column]
    
    var columnHeaderCount: Int { columns.count }
    var topFieldsCount: Int { 6 * columns.count }
    var topResultsCount: Int { columns.count }
    var middleFieldsCount: Int { 2 * columns.count }
    var middleResultsCount: Int { columns.count }
    var bottomFieldsCount: Int { 5 * columns.count }
    var bottomResultsCount: Int { columns.count }
    
    var isNewGame: Bool = true
    var lastPlayedField: Field?
    let userDefaults = UserDefaults.standard
    
    lazy var fieldsDict: [Int: [Field]] = {
        var topFields: [Field] = []
        
        for i in 0..<(columnHeaderCount + topFieldsCount + topResultsCount) {
            let indexPath = IndexPath(row: i, section: 0)
            var fieldType: FieldType = i < topFieldsCount + columnHeaderCount ? .Yamb : .Result
            if i % columns.count == 0 {
                fieldType = .RowName
            } else if i < columnHeaderCount {
                fieldType = .ColumnHeader
            }
            
            topFields.append(Field(row: Row.fromIndexPath(indexPath, numberOfColumns: columns.count),
                                   type: fieldType,
                                   column: columns.columnFrom(indexPath: indexPath),
                                   indexPath: indexPath))
        }
        
        var middleFields: [Field] = []
        for i in 0..<(middleFieldsCount + middleResultsCount) {
            let indexPath = IndexPath(row: i, section: 1)
            var fieldType: FieldType = i < middleFieldsCount ? .Yamb : .Result
            if i % columns.count == 0 {
                fieldType = .RowName
            }
            
            middleFields.append(Field(row: Row.fromIndexPath(indexPath, numberOfColumns: columns.count),
                                      type: fieldType,
                                      column: columns.columnFrom(indexPath: indexPath),
                                      indexPath: indexPath))
        }
        
        var bottomFields: [Field] = []
        for i in 0..<(bottomFieldsCount + bottomResultsCount) {
            let indexPath = IndexPath(row: i, section: 2)
            var fieldType: FieldType = i < bottomFieldsCount ? .Yamb : .Result
            if i % columns.count == 0 {
                fieldType = .RowName
            }
            
            bottomFields.append(Field(row: Row.fromIndexPath(indexPath, numberOfColumns: columns.count),
                                      type: fieldType,
                                      column: columns.columnFrom(indexPath: indexPath),
                                      indexPath: indexPath))
        }
        return [0:topFields, 1:middleFields, 2:bottomFields]
    }()
    
    var totalScore: Int {
        var sumTop = 0
        var sumMiddle = 0
        var sumBottom = 0

        fieldsDict[0]?.filter { $0.type == .Result }.forEach {
            sumTop += $0.score ?? 0
        }
        fieldsDict[0]?.filter { $0.type == .Yamb && $0.hasStar }.forEach {_ in
            sumTop += 50
        }
        fieldsDict[1]?.filter { $0.type == .Result }.forEach {
            sumMiddle += $0.score ?? 0
        }
        fieldsDict[1]?.filter { $0.type == .Yamb && $0.hasStar }.forEach {_ in
            sumMiddle += 50
        }
        fieldsDict[2]?.filter { $0.type == .Result }.forEach {
            sumBottom += $0.score ?? 0
            if $0.hasStar { sumMiddle += 50 }
        }
        fieldsDict[2]?.filter { $0.type == .Yamb && $0.hasStar }.forEach {_ in
            sumTop += 50
        }

        return sumTop + sumMiddle + sumBottom
    }
    
    var isGameEnded: Bool {
        for (_, fields) in fieldsDict {
            for field in fields where field.row != nil {
                if field.score == nil { return false }
            }
        }
        
        return true
    }
    
    func fieldTypeFor(indexPath: IndexPath) -> FieldType {
        if indexPath.section == 0 {
            if indexPath.item < columnHeaderCount { return .ColumnHeader }
            return indexPath.item < topFieldsCount ? .Yamb : .Result
        } else if indexPath.section == 1 {
            return indexPath.item < middleFieldsCount ? .Yamb : .Result
        } else if indexPath.section == 2 {
            return indexPath.item < bottomFieldsCount ? .Yamb : .Result
        }
        
        return .ColumnHeader
    }
    
    func fieldFor(indexPath: IndexPath) -> Field? {
        return fieldsDict[indexPath.section]?[indexPath.row]
    }
    
    func columnResult(column: Column, section: Int) -> Int {
        guard let fields = fieldsDict[section], columns.contains(column) else { return 0 }
        
        if section == 0 || section == 2 {
            var sum = 0
            fields.filter { $0.column == column && $0.type != .Result }.forEach{ sum += $0.score ?? 0 }
            if section == 0 && sum >= 60 { sum += 30 }
            return sum
        } else if section == 1 {
            guard let fieldsTop = fieldsDict[0], columns.contains(column),
                  let ones = fieldsTop.filter({ $0.row == .ones && $0.column == column }).first else { return 0 }
            var sum = 0
            let fields = fields.filter { $0.column == column && $0.type != .Result }
            for field in fields {
                guard let score = field.score else { return 0 }
                sum = field.row == .min ? (sum - score) : (sum + score)
            }
    
            sum *= ones.score ?? 0
            if sum >= 60 { sum += 30 }
            return sum
        }
        return 0
    }
    
    func setScore(diceRolls: [DiceRoll], indexPath: IndexPath) {
        guard let row = fieldsDict[indexPath.section]?[indexPath.item].row else { return }
        let column = columns.columnFrom(indexPath: indexPath)
        if let field = fieldsDict[indexPath.section]?[indexPath.item] {
            field.score = row.calculate(diceRolls: diceRolls)
            field.hasStar = field.row != .yamb && diceRolls.hasStar
            lastPlayedField = field
        }
        scoreField(column: column, section: indexPath.section)?.score = columnResult(column: column, section: indexPath.section)
        if row == .ones {
            scoreField(column: column, section: 1)?.score = columnResult(column: column, section: 1)
        }
        
        let fieldsData = try? PropertyListEncoder().encode(fieldsDict)
        userDefaults.setValue(fieldsData, forKey: kScoreDictKey);
        
        updateEnabledFields()
    }
    
    func loadScores() {
        if let fields = userDefaults.value(forKey: kScoreDictKey) as? Data,
           let decodedFields  = try? PropertyListDecoder().decode([Int: [Field]].self, from: fields) {
            fieldsDict = decodedFields;
        }
    }
    
    func resetScores() {
        fieldsDict = fieldsDict.mapValues { fieldArray in
            fieldArray.map { fld in
                fld.hasStar = false
                fld.score = nil
                return fld
            }
        }
        lastPlayedField = nil
        updateEnabledFields()
    }
    
    func clear(indexPath: IndexPath) {
        if let field = fieldsDict[indexPath.section]?[indexPath.item] {
            field.score = nil
            field.hasStar = false
            lastPlayedField = field
            updateEnabledFields()
        }
    }
    
    func updateEnabledFields() {
        for (_, fields) in fieldsDict {
            for dictField in fields {
                dictField.isEnabled = isRequirementFullfilled(field: dictField)
            }
        }
    }
    
    func scoreField(column: Column, section: Int) -> Field? {
        guard let fields = fieldsDict[section] else { return nil }
        for field in fields where (field.column == column && field.type == .Result) {
            return field
        }
        return nil
    }
    
    init(columns: [Column]) {
        self.columns = columns
        
        updateEnabledFields()
    }
    
    func isRequirementFullfilled(field: Field) -> Bool {
        if field.score != nil && field != lastPlayedField { return false }
        
        switch field.column {
        case .down:
            if field.row == .ones { return true }
            for (_, fields) in fieldsDict {
                for dictField in fields where dictField.column == field.column {
                    if let dictRowValue = dictField.row?.rawValue, let fieldRowValue = field.row?.rawValue {
                        if dictRowValue == fieldRowValue - 1 { return dictField.score != nil }
                    }
                }
            }
            return false
        case .up:
            if field.row == .yamb { return true }
            for (_, fields) in fieldsDict {
                for dictField in fields where dictField.column == field.column {
                    if let dictRowValue = dictField.row?.rawValue, let fieldRowValue = field.row?.rawValue {
                        if fieldRowValue + 1 == dictRowValue {
                            return dictField.score != nil
                            
                        }
                    }
                }
            }
            return false
        case .free: return true
        case .midOut:
            if field.row == .min || field.row == .max { return true }
            for (_, fields) in fieldsDict {
                for dictField in fields where dictField.column == field.column {
                    if let dictRowValue = dictField.row?.rawValue, let fieldRowValue = field.row?.rawValue {
                        if fieldRowValue < Row.max.rawValue {
                            if fieldRowValue + 1 == dictRowValue {
                                return dictField.score != nil
                            }
                        } else if fieldRowValue > Row.min.rawValue {
                            if fieldRowValue - 1 == dictRowValue {
                                return dictField.score != nil
                            }
                        }
                    }
                }
            }
            return false
        case .outMid:
            if field.row == .ones || field.row == .yamb { return true }
            for (_, fields) in fieldsDict {
                for dictField in fields where dictField.column == field.column {
                    if let dictRowValue = dictField.row?.rawValue, let fieldRowValue = field.row?.rawValue {
                        if fieldRowValue <= Row.max.rawValue {
                            if fieldRowValue - 1 == dictRowValue {
                                return dictField.score != nil
                            }
                        } else if fieldRowValue >= Row.min.rawValue {
                            if fieldRowValue + 1 == dictRowValue {
                                return dictField.score != nil
                            }
                        }
                    }
                }
            }
            return false
        case .announce: return true
        case .disannounce: return true
        case .hand: return true
        case .rowNames: return false
        }
    }
}

class Field: Equatable, Codable {
    static func == (lhs: Field, rhs: Field) -> Bool {
        return lhs.indexPath == rhs.indexPath
    }
    
    var row: Row?
    var type: FieldType
    var column: Column
    var indexPath: IndexPath
    var score: Int?
    var hasStar: Bool = false
    
    var isEnabled: Bool
    
    init(row: Row?, type: FieldType, column: Column, indexPath: IndexPath) {
        self.row = row
        self.type = type
        self.column = column
        self.indexPath = indexPath
        self.isEnabled = true
    }
}
