//
//  TuningTableViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 15.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout

protocol TuningTableViewControllerDelegate: AnyObject {
    
    func didChangeTuning()
}

class TuningTableViewController: UITableViewController {

    weak var tuningDelegate: TuningTableViewControllerDelegate?
    var iapController: InAppPurchaseViewController?
    
    var activeIndexPath = IndexPath(item: 0, section: 0)
    
    var sections = [GroupedSection<Int, Tuning>]()
    
    
    var instrument: Instrument!
    var tunings: [Tuning]?  {
        didSet {
            
            if tunings == nil { return }
            
            self.sections = GroupedSection.group(rows: tunings!, by: { $0.notes!.count })
            self.sections.sort { lhs, rhs in lhs.sectionItem < rhs.sectionItem }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPerformIAP), name: .didPerformIAP, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.rows.count
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPatternLight.png")!)
        
        let section = self.sections[section]
        let text = String(format: NSLocalizedString("%d Label.strings", comment: ""), section.sectionItem) 
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)
        label.text = text
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0.5
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        label.layer.masksToBounds = false
        
        headerView.addSubview(label)
        label.autoCenterInSuperview()
        
        let borderView = UIView()
        borderView.backgroundColor = .darkGray
        headerView.addSubview(borderView)
        
        borderView.autoPinEdge(.left, to: .left, of: headerView)
        borderView.autoPinEdge(.right, to: .right, of: headerView)
        borderView.autoPinEdge(.bottom, to: .bottom, of: headerView)
        borderView.autoSetDimension(.height, toSize: 2)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TuningTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tuningCell", for: indexPath) as! TuningTableViewCell
        cell.selectionStyle = .none
        
        let section = self.sections[indexPath.section]
        
        let tuning = section.rows[indexPath.row]
        guard let notes = tuning.notes else { return cell }
        
        var noteString = ""
        for (index, note) in notes.enumerated() {
            
            if index < notes.count - 1 {
                noteString += "\(note) - "
            } else {
                noteString += "\(note)"
            }
        }
        
        cell.titleLabel.text = tuning.name
        cell.subtitleLabel.text = noteString
    
        cell.standardIndicatorView.alpha = tuning.isStandard == true ? 1.0 : 0.0
        
        if indexPath.totalRow(tableView: tableView) == Utils().getTuningId() {
            cell.switchButton.image = UIImage(named: "onButton")
            activeIndexPath = indexPath
        } else {
            cell.switchButton.image = UIImage(named: "offButton")
        }
        
        guard let instrumentName = instrument.name, let dict = dictIAP[instrumentName], let isOpenInstrument = dict[instrumentName] else {
            return cell
        }
        
        if isOpenInstrument() == false && tuning.isStandard == false  {
            cell.switchButton.image = UIImage(named: "shoppingCart")
            cell.isLocked = true
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: TuningTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tuningCell", for: indexPath) as! TuningTableViewCell
        
        let section = self.sections[indexPath.section]
        let tuning = section.rows[indexPath.row]
        
        guard let instrumentName = instrument.name, let dict = dictIAP[instrumentName], let isOpenInstrument = dict[instrumentName] else {
            return
        }
        
        if isOpenInstrument() == false && tuning.isStandard == false  {
            performSegue(withIdentifier: "iapSegue", sender: true)
            return
        }

        Utils().saveTuning(index: indexPath.totalRow(tableView: tableView))
        cell.switchButton.image = UIImage(named: "onButton")
        
        tableView.reloadData()
        
        tuningDelegate?.didChangeTuning()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if identifier == "iapSegue" {
            guard let _ = sender as? Bool else { return false }
            return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? InAppPurchaseViewController {
            iapController = vc
            iapController?.instrument = instrument
        }
    }

    @objc func didPerformIAP(_ notification: Notification) {
        
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct GroupedSection<SectionItem : Hashable, RowItem> {
    
    var sectionItem : SectionItem
    var rows : [RowItem]
    
    static func group(rows : [RowItem], by criteria : (RowItem) -> SectionItem) -> [GroupedSection<SectionItem, RowItem>] {
        let groups = Dictionary(grouping: rows, by: criteria)
        return groups.map(GroupedSection.init(sectionItem:rows:))
    }
    
}


extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}

extension IndexPath {
    func totalRow(tableView: UITableView) -> Int {
        var rowNumber = self.row
        for i in 0..<self.section {
            rowNumber += tableView.numberOfRows(inSection: i)
        }
        return rowNumber
    }
}
