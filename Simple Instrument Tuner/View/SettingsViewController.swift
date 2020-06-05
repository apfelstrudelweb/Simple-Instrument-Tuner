//
//  SettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 05.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

import fluid_slider
import PureLayout
import StoreKit
import EasyTipView

protocol SettingsViewControllerDelegate: class {
    
    func didChangeInstrument()
    func didChangeTuning()
}


class SettingsViewController: UIViewController, TuningTableViewControllerDelegate, PKIAPHandlerDelegate, EasyTipViewDelegate {
    
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var instrumentDropDown: DropDown!
    @IBOutlet weak var embeddedCalibrationView: UIView!
    @IBOutlet weak var iapButtonView: UIView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var instrumentDropdownLabel: UILabel!
    @IBOutlet weak var colorSettingsView: UIView!
    @IBOutlet weak var colorSettingsLabel: UILabel!
    @IBOutlet weak var colorSettingsButton: UIButton!
    @IBOutlet weak var goldSettingsButton: UIButton!
    @IBOutlet weak var goldGradientImageView: UIImageView!
    @IBOutlet weak var colorPurchaseButton: UIButton!
    @IBOutlet weak var goldGradientView: UIImageView!
    
    @IBOutlet weak var labelHeight: NSLayoutConstraint!
    @IBOutlet weak var dropdownHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    private var embeddedTuningViewController: TuningTableViewController!
    var embeddedCalibrationViewController: CalibrationViewController!
    
    var headerColor = UIColor.red {
        didSet {
            self.closeButton.backgroundColor = headerColor
            
            if UserDefaults.standard.bool(forKey: "gold") == true {
                goldGradientView.alpha = 1.0
                self.closeButton.backgroundColor = .clear
                setDropdownColor()
            } else {
                self.instrumentDropDown.arrowColor = headerColor
                self.instrumentDropDown.selectedRowColor = headerColor
                goldGradientView.alpha = 0.0
            }
        }
    }
    
    var backgroundColor = UIColor.black {
        didSet {
            self.view.backgroundColor = backgroundColor
            
            setDropdownColor()
            
//            self.instrumentDropDown.backgroundColor = backgroundColor.darker(by: 10)!
//            self.instrumentDropDown.rowBackgroundColor = self.instrumentDropDown.backgroundColor!
        }
    }
    
    weak var settingsDelegate: SettingsViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TuningTableViewController,
            segue.identifier == "tuningSegue" {
            embeddedTuningViewController = vc
            embeddedTuningViewController.tuningDelegate = self
        }
        if let vc = segue.destination as? CalibrationViewController,
            segue.identifier == "calibrationSegue" {
            embeddedCalibrationViewController = vc
        }
        if let vc = segue.destination as? ColorSettingsViewController,
            segue.identifier == "colorSettingsSegue" {
            vc.headerColor = self.closeButton.backgroundColor!
            vc.backgroundColor = self.view.backgroundColor!
        }
    }
    
    
    fileprivate func showTooltip() {
        
        EasyTipView.show(forView: self.instrumentDropDown,
                         withinSuperview: self.view,
                         text: NSLocalizedString("Info.selectInstrument", comment: ""),
                         preferences: EasyTipView.globalPreferences,
                         delegate: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        if Bundle.appTarget == "Simple Banjo Tuner" || Bundle.appTarget == "Simple Ukulele Tuner" {
            instrumentDropDown.isHidden = true
            instrumentDropdownLabel.isHidden = true
            labelHeight.constant = 0
            dropdownHeight.constant = 0
        }
        
        scrollView.delaysContentTouches = false
        
        closeButton.setTitle(NSLocalizedString("Button.close", comment: ""), for: .normal)
        
        PKIAPHandler.shared.pkiDelegate = self
        
        closeButton.isEnabled = Utils().getInstrument() == nil ? false : true
        upgradeButton.isEnabled = closeButton.isEnabled
        restoreButton.isEnabled = closeButton.isEnabled
        
        handleInstrumentsList()
        handleTuningsList()
        
        embeddedTuningViewController.tableView.layer.borderColor = #colorLiteral(red: 0.1529633105, green: 0.1679426432, blue: 0.1874132752, alpha: 1)
        embeddedTuningViewController.tableView.layer.borderWidth = 2.0
        embeddedTuningViewController.tableView.layer.masksToBounds = true
        embeddedTuningViewController.tableView.layer.cornerRadius = 4
        
        instrumentDropDown.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        instrumentDropDown.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        instrumentDropDown.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        instrumentDropDown.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        
        embeddedCalibrationView.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        embeddedCalibrationView.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        embeddedCalibrationView.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        embeddedCalibrationView.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        
        iapButtonView.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        iapButtonView.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        iapButtonView.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        iapButtonView.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        iapButtonView.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPattern.png")!)
        
        colorSettingsView.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        colorSettingsView.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        colorSettingsView.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        colorSettingsView.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        colorSettingsView.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPattern.png")!)
        
        let fact: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0.3 : 0.5
        
        colorSettingsButton.layer.cornerRadius = fact * colorSettingsButton.frame.size.height
        colorSettingsButton.clipsToBounds = true
        
        goldGradientImageView.layer.cornerRadius = fact * goldGradientImageView.frame.size.height
        goldGradientImageView.layer.masksToBounds = true
        
        colorSettingsButton.applyGradient(colors: [UIColor.green.cgColor, UIColor.yellow.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor, UIColor.blue.cgColor])
        
        if IAPHandler().isOpenPremium() == true {
            upgradeButton.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPerformIAP), name: .didPerformIAP, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeHeaderColor), name: NSNotification.Name(rawValue: "didChangeHeaderColor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeMainViewColor), name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil)
        
        if Utils().getInstrument() == nil {
            showTooltip()
        }
        
        setDropdownColor()
        
        
        
        #if BANJO
        colorSettingsButton.isEnabled = IAPHandler().isOpenBanjo() == true
        colorSettingsButton.alpha = colorSettingsButton.isEnabled ? 1.0 : 0.6
        
        goldSettingsButton.isEnabled = IAPHandler().isOpenBanjo() == true
        goldGradientImageView.alpha = goldSettingsButton.isEnabled ? 1.0 : 0.6
        
        colorPurchaseButton.isHidden = IAPHandler().isOpenBanjo() == true
        #endif
        
        #if UKULELE
        colorSettingsButton.isEnabled = IAPHandler().isOpenUkulele() == true
        colorSettingsButton.alpha = colorSettingsButton.isEnabled ? 1.0 : 0.6
        
        goldSettingsButton.isEnabled = IAPHandler().isOpenBanjo() == true
        goldGradientImageView.alpha = goldSettingsButton.isEnabled ? 1.0 : 0.6
        
        colorPurchaseButton.isHidden = IAPHandler().isOpenUkulele() == true
        #endif
        
        
        #if INSTRUMENT
        colorSettingsButton.isEnabled = IAPHandler().isOpenColor() == true
        colorSettingsButton.alpha = colorSettingsButton.isEnabled ? 1.0 : 0.6
         
        goldSettingsButton.isEnabled = IAPHandler().isOpenColor() == true
        goldGradientImageView.alpha = goldSettingsButton.isEnabled ? 1.0 : 0.6
         
        colorPurchaseButton.isHidden = IAPHandler().isOpenColor() == true
        #endif
    }
    
    @objc func didChangeHeaderColor(_ notification: Notification) {
        
        if let color = notification.userInfo?["color"] as? UIColor {
            headerColor = color
        }
    }
    
    @objc func didChangeMainViewColor(_ notification: Notification) {
        
        if let color = notification.userInfo?["color"] as? UIColor {
            backgroundColor = color
        }
    }
    
    fileprivate func setDropdownColor() {
 
        if UserDefaults.standard.bool(forKey: "gold") == true {
            instrumentDropDown.backgroundColor = UIColor(patternImage: UIImage(named: "goldGradientButton")!)
            self.instrumentDropDown.arrowColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            self.instrumentDropDown.selectedRowColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {

            if let color = UserDefaults.standard.colorForKey(key: "mainViewColor") {
                instrumentDropDown.backgroundColor = color //.withSaturationOffset(offset: -0.5)
            }
        }
        instrumentDropDown.rowBackgroundColor = instrumentDropDown.backgroundColor!
    }
    
    func makeGradientLayer(`for` object : UIView, startPoint : CGPoint, endPoint : CGPoint, gradientColors : [Any]) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = gradientColors
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = CGRect(x: 0, y: 0, width: object.frame.size.width, height: object.frame.size.height)
        return gradient
    }
    
    
    fileprivate func handleInstrumentsList() {
        
        let options = Utils().getInstrumentsArray()
        
        instrumentDropDown.optionIds = options.ids
        instrumentDropDown.optionArray = options.names!
        instrumentDropDown.optionImageArray = options.images!
        
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_INSTRUMENT_ID) {
            let currentInstrumentId = receivedData.to(type: Int.self)
            instrumentDropDown.selectedIndex = currentInstrumentId
            instrumentDropDown.text = instrumentDropDown.optionArray[instrumentDropDown.selectedIndex ?? 0]
        }
        
        instrumentDropDown.didSelect{(selectedText , index ,id) in
            
            self.closeButton.isEnabled = true
            Utils().dismisAllTooltips(view: self.view)
            
            Utils().saveInstrument(index: index)
            self.settingsDelegate?.didChangeInstrument()
            self.handleTuningsList()
            
            let index = Utils().getTuningId()
            
            Utils().saveTuning(index: index)
            self.settingsDelegate?.didChangeTuning()
        }
    }
    
    fileprivate func handleTuningsList() {
        
        embeddedTuningViewController.instrument = Utils().getInstrument()
        embeddedTuningViewController.tunings = Utils().getInstrument()?.tunings
        embeddedTuningViewController.tableView.reloadData()
    }
    
    // MARK: TuningTableViewControllerDelegate
    func didChangeTuning() {
        self.settingsDelegate?.didChangeTuning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func colorPurchaseButtonTouched(_ sender: Any) {
        performSegue(withIdentifier: "iapSegue", sender: true)
    }
    
    @IBAction func colorSettingsButtonTouched(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "gold")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeGold"), object: nil, userInfo: nil)
        if let _headerColor = UserDefaults.standard.colorForKey(key: "headerColor") {
            headerColor = _headerColor
        }
        goldGradientView.alpha = 0.0
    }
    
    @IBAction func goldSettingsButtonTouched(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "gold")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeGold"), object: nil, userInfo: nil)
        self.headerColor = .clear
        goldGradientView.alpha = 1.0
    }
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeButtonTouched(_ sender: Any) {
        //performSegue(withIdentifier: "iapSegue", sender: self)
    }
    
    @IBAction func restoreButtonTouched(_ sender: Any) {
        PKIAPHandler.shared.restorePurchase()
    }
    
    // MARK
    func productsRestored(products: [String]) {
        
        if products.count == 0 {
            self.showAlert(title: NSLocalizedString("Info", comment: ""), msg: NSLocalizedString("IAP.alert.noitems", comment: "") )
            return
        }
        
        var alertText = NSLocalizedString("IAP.alert.items", comment: "")
        
        for product in products {
            if let productTitle = iapIdentifierDict[product] {
                alertText += "\n- \(productTitle) -"
                
                IAPHandler().dictUnlockMethods[productTitle]!()
            }
        }
        
        NotificationCenter.default.post(name: .didPerformIAP, object: nil)
        
        self.showAlert(title: NSLocalizedString("Success", comment: ""), msg: alertText)
        
        if IAPHandler().isOpenPremium() == true {
            upgradeButton.isEnabled = false
        }
    }
    
    @objc func didPerformIAP(_ notification: Notification) {
        
        if IAPHandler().isOpenPremium() == true {
            upgradeButton.isEnabled = false
        }
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension Bundle {
    
    public static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    public static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    public static func _version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    public static var appTarget: String? {
        if let targetName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
            return targetName
        }
        return nil
    }
}


extension UIButton {
    
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        //gradientLayer.cornerRadius = self.frame.height/2
        
        gradientLayer.shadowColor = UIColor.black.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 1
        gradientLayer.masksToBounds = true
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        
    }
}


extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            
            if r < 0.25 && g < 0.25 && b < 0.25 { return self }
            
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}
