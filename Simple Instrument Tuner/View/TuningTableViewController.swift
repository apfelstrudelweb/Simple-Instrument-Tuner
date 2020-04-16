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
    
    var sections = [GroupedSection<Int, Tuning>]()
    
    var tunings: [Tuning]?  {
        didSet {
            
            if tunings == nil { return }
            
            self.sections = GroupedSection.group(rows: tunings!, by: { $0.notes!.count })
            self.sections.sort { lhs, rhs in lhs.sectionItem < rhs.sectionItem }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPatternLight.png")!)
        
        let section = self.sections[section]
        let text = "\(section.sectionItem) Strings"
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tunings?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TuningTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tuningCell", for: indexPath) as! TuningTableViewCell
        
        guard let tuning = tunings?[indexPath.row], let notes = tuning.notes else { return cell }

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
        
//        if tuning.isStandard == true {
//            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 0.25*cell.bounds.size.height)
//            cell.subtitleLabel.font = UIFont.boldSystemFont(ofSize: 0.2*cell.bounds.size.height)
//        } else {
//            cell.titleLabel.font = UIFont.systemFont(ofSize: 0.25*cell.bounds.size.height)
//            cell.subtitleLabel.font = UIFont.systemFont(ofSize: 0.2*cell.bounds.size.height)
//        }
        
        if indexPath.row ==  Utils().getTuningId() {
            cell.buttonSwitch.setImage(UIImage(named: "onButton"), for: .normal)
        } else {
            cell.buttonSwitch.setImage(UIImage(named: "offButton"), for: .normal)
        }
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //super.tableView(tableView, didSelectRowAt: indexPath)
        
        let cell: TuningTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tuningCell", for: indexPath) as! TuningTableViewCell
        
        Utils().saveTuning(index: indexPath.row)
        cell.buttonSwitch.setImage(UIImage(named: "onButton"), for: .normal)
        
        tableView.reloadData()
        
        tuningDelegate?.didChangeTuning()
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
