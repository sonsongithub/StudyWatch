//
//  ViewController.swift
//  StudyWatch
//
//  Created by sonson on 2017/05/05.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var longHand: LongHandView!
    @IBOutlet var shortHand: ShortHandView!
    @IBOutlet var backView: BackView!
    
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var decideButton: UIButton!
    
    let synthesizer = AVSpeechSynthesizer()
    
    var goodSound: AVAudioPlayer!
    var badSound: AVAudioPlayer!
    var questionSound: AVAudioPlayer!
    
    var level: Level = .easy {
        didSet {
            picker.reloadAllComponents()
            nextQuestion()
        }
    }
    
    enum Level: Int {
        case easy = 0
        case midium = 1
        case difficult = 2
    }
    
    func nextQuestion() {
        self.hour = Int(arc4random() % 12)
        
        
        switch level {
        case .easy:
            self.minute = Int(arc4random() % 4) * 0
        case .midium:
            self.minute = Int(arc4random() % 12) * 5
        case .difficult:
            self.minute = Int(arc4random() % 60)
        }
        
        self.questionSound.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backView.layoutIfNeeded()
        backView.setNeedsLayout()
        backView.layoutLabels()
    }
    
    var speakingText: String {
        if minute == 0 {
            return "せいかいは\(hour)じでした"
        } else {
            return "せいかいは\(hour)じ\(minute)ふんでした"
        }
    }
    
    @IBAction func decide(sender: Any) {
        print(#function)
        
        if check() {
            goodSound.play()
            if !synthesizer.isSpeaking {
                let utterance = AVSpeechUtterance(string: speakingText)
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                synthesizer.speak(utterance)
            }
            let alert = UIAlertController(title: "正解!", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                self.nextQuestion()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            badSound.play()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 2000000)) {
//        }
        
    }
    
    func check() -> Bool {
        let ansHour = picker.selectedRow(inComponent: 0)
        let ansMinute = picker.selectedRow(inComponent: 1)
        
        switch level {
        case .easy:
            if hour == ansHour && minute == ansMinute * 0 {
                return true
            }
        case .midium:
            if hour == ansHour && minute == ansMinute * 5 {
                return true
            }
        case .difficult:
            if hour == ansHour && minute == ansMinute {
                return true
            }
        }
        return false
    }
    
    @IBAction func level(sender: Any) {
        print(#function)
        if let seg = sender as? UISegmentedControl {
            print(seg.selectedSegmentIndex)
            switch seg.selectedSegmentIndex {
            case 0:
                self.level = .easy
            case 1:
                self.level = .midium
            case 2:
                self.level = .difficult
            default:
                self.level = .difficult
            }
        }
    }
    
    //表示列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //表示個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        } else {
            switch level {
            case .easy:
                return 1
            case .midium:
                return 12
            case .difficult:
                return 60
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row)"
        } else {
            switch level {
            case .easy:
                return "\(row * 15)"
            case .midium:
                return "\(row * 5)"
            case .difficult:
                return "\(row)"
            }
        }
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("列: \(row)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let position = touch.location(in: self.view)
//        let x = position.x - self.view.frame.size.width / 2
//        let y = position.y - self.view.frame.size.height / 2
//        
//        let rad = atan2(y, x)
//        print(rad)
//    }
    
    var hour: Int = 0 {
        didSet {
            updateHands()
        }
    }
    
    var minute: Int = 0 {
        didSet {
            updateHands()
        }
    }
    
    func updateHands(){
        var shortHandRad = 2 * CGFloat.pi / 12 * CGFloat(hour)
        shortHandRad += 2 * CGFloat.pi / 12 / CGFloat(60) * CGFloat(minute)
        let longHandRad = 2 * CGFloat.pi / CGFloat(60) * CGFloat(minute)
        
        longHand.transform = CGAffineTransform(rotationAngle: longHandRad)
        shortHand.transform = CGAffineTransform(rotationAngle: shortHandRad)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hour = 10
        minute = 44
        
        do {
            guard let path = Bundle.main.path(forResource: "good", ofType: "mp3") else { return }
            let url = URL(fileURLWithPath: path)
            let player = try AVAudioPlayer(contentsOf: url)
            goodSound = player
        } catch {
            print(error)
        }
        do {
            guard let path = Bundle.main.path(forResource: "question", ofType: "mp3") else { return }
            let url = URL(fileURLWithPath: path)
            let player = try AVAudioPlayer(contentsOf: url)
            questionSound = player
        } catch {
            print(error)
        }
        do {
            guard let path = Bundle.main.path(forResource: "wrong", ofType: "mp3") else { return }
            let url = URL(fileURLWithPath: path)
            let player = try AVAudioPlayer(contentsOf: url)
            badSound = player
        } catch {
            print(error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 1000000)) { 
            self.nextQuestion()
        }
    }
}

