//
//  Utils.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 07.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

struct Tuning {
    var noteNames: [String]?
    var frequencies: [CGFloat]?
}

struct Instrument {
    var name: String?
    var symbol: UIImage?
    var tuning: Tuning?
}

class Utils: NSObject {
    
    func getInstrument() -> Instrument? {
        
        guard let path = Bundle.main.path(forResource: INSTRUMENTS_PLIST_FILE, ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return nil }
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_INSTRUMENT_ID) {
            let currentInstrumentId = receivedData.to(type: Int.self)
            guard let dict = array[currentInstrumentId] as? NSDictionary, let name = dict.value(forKey: "name") as? String, let image = dict.value(forKey: "image") as? String else {
                return nil
            }
            
            guard let tuningsDict = dict.value(forKey: "tunings") as? NSDictionary, let standardDict = tuningsDict.value(forKey: "standard") as? NSDictionary else { return nil }
            let notes = standardDict.value(forKey: "notes") as? [String]
            let frequencies = standardDict.value(forKey: "frequencies") as? [CGFloat]
            
            let tuning = Tuning(noteNames: notes, frequencies: frequencies)
            
            return Instrument(name: name, symbol: UIImage(named: image), tuning: tuning)
            
        }
        return nil
    }
    
    func getCurrentNoteObjects() -> [Note]? {
        
        let instrument = getInstrument()
        
        let noteNames = instrument?.tuning?.noteNames
        
        var iter = noteNames?.makeIterator()
        var notes = [Note]()

        while let noteName: String = iter?.next() {
            
            let noteLetter = noteName[0]
            let octave: Float = Float(noteName[1])!
            
            let baseFrequency:NSNumber = notesDict.value(forKey: noteLetter) as! NSNumber
            let frequency = baseFrequency.floatValue * pow(2.0, octave)
            
            //print(frequency)
            
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
    
    func getFrequencyFromMidiNoteNumber(index: Int) -> Float {
        
        let notes = getCurrentNoteObjects()
        if let object = notes!.filter({ $0.number == index }).first {
            return object.frequency
        } else {
            return 0.0
        }
    }
    
    func getCurrentCalibration() -> Float {
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_CALIBRATION) {
            let currentCalibration = receivedData.to(type: Int.self)
            return Float(currentCalibration)
        } else {
            return 440.0
        }
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
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }
}
