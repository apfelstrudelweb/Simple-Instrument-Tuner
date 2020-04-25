//
//  Utils.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 07.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

struct Tuning {
    var name: String?
    var isStandard: Bool?
    var notes: [String]?
    var frequencies: [CGFloat]?
}

struct Instrument {
    var name: String?
    var symbol: UIImage?
    var doubleStrings: Bool?
    var tunings: [Tuning]?
}

struct InstrumentsOptions {
    var ids: [Int]?
    var names: [String]?
    var images: [String]?
}

class Utils: NSObject {
    
    func getInstrument() -> Instrument? {
        
        guard let path = Bundle.main.path(forResource: INSTRUMENTS_PLIST_FILE, ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return nil }
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_INSTRUMENT_ID) {
            let currentInstrumentId = receivedData.to(type: Int.self)
            guard let dict = array[currentInstrumentId] as? NSDictionary, let name = dict.value(forKey: "name") as? String, let image = dict.value(forKey: "image") as? String, let doubleStrings = dict.value(forKey: "doubleStrings") as? Bool else {
                return nil
            }
            
            guard let tuningsArray = dict.value(forKey: "tunings") as? [NSDictionary] else { return nil }
            
            var tunings = [Tuning]()
            
            for dict in tuningsArray {
                guard let name = dict.value(forKey: "tuningName") as? String, let notes = dict.value(forKey: "notes") as? [String], let isStandard = dict.value(forKey: "standard") as? Bool else { continue }
                
                var frequencies = [CGFloat]()
                
                for note in notes {
                    let frequency = getFrequencyFromNote(note: note)
                    frequencies.append(frequency)
                }
                
                tunings.append(Tuning(name: name, isStandard: isStandard, notes: notes, frequencies: frequencies))
            }
            
            return Instrument(name: name, symbol: UIImage(named: image), doubleStrings: doubleStrings, tunings: tunings)
            
        }
        return nil
    }
    
    func saveInstrument(index: Int) {
        
        let key = KEYCHAIN_CURRENT_INSTRUMENT_ID
        
        let data = Data(from: index)
        let _ = KeyChain.save(key: key, data: data)
    }
    
    func getTuningId() -> Int {
        
        var currentTuningId = 0
        guard let instrumentName = getInstrument()?.name else { return 0 }
        let key = KEYCHAIN_CURRENT_TUNING_ID + instrumentName
        
        if let receivedData = KeyChain.load(key: key) {
            currentTuningId = receivedData.to(type: Int.self)
        }
        return currentTuningId
    }
    
    func getInstrumentsArray() -> InstrumentsOptions {
        
        guard let path = Bundle.main.path(forResource: INSTRUMENTS_PLIST_FILE, ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return InstrumentsOptions() }
        
        var idArray = [Int]()
        var nameArray = [String]()
        var imageArray = [String]()
        
        for instrument in array.enumerated() {
            let dict = instrument.element as! NSDictionary
            
            guard let name = dict.value(forKey: "name") as? String, let image = dict.value(forKey: "image") as? String, let id = dict.value(forKey: "id") as? Int else { continue }
            
            idArray.append(id)
            nameArray.append(name)
            imageArray.append(image)
        }
    
        return InstrumentsOptions(ids: idArray, names: nameArray, images: imageArray)
    }
    
    func getTuningsArray() -> [String] {
        
        guard let instrument = getInstrument(), let tunings = instrument.tunings else { return [] }
        
        //let filteredTunings = tunings.filter({ $0.isStandard == true })
        
        var optionArray = [String]()
        
        for tuning in tunings {
            guard let name = tuning.name else { continue }
            guard let notes = tuning.notes else { continue }
            guard let isStandard = tuning.isStandard else { continue }
            
            var noteString = ""
            for (index, note) in notes.enumerated() {
                
                if index < notes.count - 1 {
                    noteString += "\(note) - "
                } else {
                    noteString += "\(note)"
                }
            }
            
            let string = isStandard == true ? "## \(name) ## ---\(noteString)" : "\(name) ---\(noteString)"
            optionArray.append(string)
        }
        return optionArray
    }
    
    func saveTuning(index: Int) {
        
        let instrument = getInstrument()
        guard let instrumentName = instrument?.name else { return }
        let key = KEYCHAIN_CURRENT_TUNING_ID + instrumentName
        
        let data = Data(from: index)
        let _ = KeyChain.save(key: key, data: data)
    }
    
    func getFrequencyFromNote(note: String) -> CGFloat {
        
        guard let noteLetter: String = note.match("[A-Z]♯*").first?.first else { return 0.0 }
        guard let octaveString: String = note.match("[0-9]").first?.first else { return 0.0 }
        guard let octave = Float(octaveString) else { return 0.0 }
        guard let baseFrequency:NSNumber = notesDict.value(forKey: noteLetter) as? NSNumber else { return 0.0 }
        return CGFloat(baseFrequency.floatValue * pow(2.0, octave))
    }
    
    func getCurrentNoteObjects() -> [Note]? {
        
        let instrument = getInstrument()
        
        guard let instrumentName = instrument?.name else { return [] }
        
        var currentTuningId: Int = 0
        let key = KEYCHAIN_CURRENT_TUNING_ID + instrumentName
        if let receivedData = KeyChain.load(key: key) {
            currentTuningId = receivedData.to(type: Int.self)
        }
        
        guard let tunings = instrument?.tunings else { return [] }
        if currentTuningId > tunings.count - 1 {
            currentTuningId = 0
        }
        guard let noteNames = tunings[currentTuningId].notes else { return [] }
        guard let frequencies = instrument?.tunings?[currentTuningId].frequencies else { return [] }
        
        var iter1 = noteNames.makeIterator()
        var iter2 = frequencies.makeIterator()
        
        var notes = [Note]()
        
        while let noteName: String = iter1.next(), let frequency = iter2.next() {
            
            notes.append(Note(noteName: noteName, frequency: Float(frequency)))
        }
        
        return notes
    }
    
    func getCurrentFrequencies() -> [Float] {
        
        var frequencies = [Float]()
        let notes: [Note] = getCurrentNoteObjects()!
        
        for note in notes {
            frequencies.append(note.frequency)
        }
        return frequencies
    }
    
    func getCurrentTuningName() -> String {
        
        let instrument = getInstrument()
        
        guard let instrumentName = instrument?.name else { return "" }
        let key = KEYCHAIN_CURRENT_TUNING_ID + instrumentName
        
        guard let receivedData = KeyChain.load(key: key) else { return "" }
        
        var currentTuningId = receivedData.to(type: Int.self)
        
        guard let tunings = instrument?.tunings else { return "" }
        if currentTuningId > tunings.count - 1 {
            currentTuningId = 0
        }
        
        guard let name = tunings[currentTuningId].name else { return "" }
        
        return name
    }
    
    
    func getCurrentCalibration() -> Float {
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_CALIBRATION) {
            let currentCalibration = receivedData.to(type: Int.self)
            return Float(currentCalibration)
        } else {
            return chambertone
        }
    }
    
    func getOctaveFrom(frequency: Float) -> Int {
        
        var freq = Float(frequency)
        while (freq > Float(freqArray.last!)) {
            freq = freq / 2.0
        }
        while (freq < Float(freqArray.first!)) {
            freq = freq * 2.0
        }
        
        let octave = Int(log2f(Float(frequency) / freq))
        return octave
    }
    
    func generateBulletList(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 4,
             textColor: UIColor = .white,
             bulletColor: UIColor = .white) -> NSAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation

        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }
    
}

extension Array where Element: FloatingPoint {
    
    func sum() -> Element {
        return self.reduce(0, +)
    }
    
    func avg() -> Element {
        return self.sum() / Element(self.count)
    }
    
    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }
    
}

extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
            } ?? []
    }
    
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }
}

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }

    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }

    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }

    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}
