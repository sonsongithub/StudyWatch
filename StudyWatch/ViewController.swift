//
//  ViewController.swift
//  StudyWatch
//
//  Created by sonson on 2017/05/05.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import AVFoundation

enum Level: Int {
    case novice = 60
    case basic = 30
    case fundamental = 15
    case intermediate = 10
    case advanced = 5
    case professional = 1
    
    var hour: Int {
        return Int(arc4random() % 12)
    }
    
    var step: UInt32 {
        return UInt32(60 / self.rawValue)
    }
    
    var minute: Int {
        return Int(arc4random() % self.step) * self.rawValue
    }
    
    func hour(at index: Int) -> Int {
        return index
    }
    
    func minute(at index: Int) -> Int {
        return self.rawValue * index
    }

    var time: Time {
        return Time(hour: hour, minute: minute)
    }
    
    static func create(with index: Int) -> Level {
        switch index {
        case 0:
            return .novice
        case 1:
            return .basic
        case 2:
            return .fundamental
        case 3:
            return .intermediate
        case 4:
            return .advanced
        case 5:
            return .professional
        default:
            return .novice
        }
    }
    
    var numberOfRowsInMinuteComponent: Int {
        return Int(step)
    }
    
    func titleFor(row: Int) -> String {
        return "\(row * self.rawValue)"
    }
}

struct Time: Equatable {
    let hour: Int
    let minute: Int
    
    var speakingText: String {
        if minute == 0 {
            return "\(hour)じでした"
        } else {
            return "\(hour)じ\(minute)ふんでした"
        }
    }
    
    static func == (left : Time, right : Time) -> Bool {
        return (left.hour == right.hour && left.minute == right.minute)
    }
}

extension UIPickerView {
    func time(level: Level) -> Time {
        let indexOfHour = self.selectedRow(inComponent: 0)
        let indexOfMinute = self.selectedRow(inComponent: 1)
        return Time(hour: level.hour(at: indexOfHour), minute: level.minute(at: indexOfMinute))
    }
}

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
    
    var time: Time = Time(hour: 0, minute: 0) {
        didSet {
            updateHands()
        }
    }
    
    var level: Level = .novice {
        didSet {
            picker.reloadAllComponents()
            nextQuestion()
        }
    }
    
    func nextQuestion() {
        time = level.time
        self.questionSound.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backView.layoutIfNeeded()
        backView.setNeedsLayout()
        backView.layoutLabels()
    }
    
    @IBAction func decide(sender: Any) {
        if check() {
            goodSound.play()
            if !synthesizer.isSpeaking {
                let utterance = AVSpeechUtterance(string: time.speakingText)
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
    }
    
    func check() -> Bool {
        let input = picker.time(level: level)
        return input == time
    }
    
    @IBAction func level(sender: Any) {
        if let segment = sender as? UISegmentedControl {
            level = Level.create(with: segment.selectedSegmentIndex)
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
            return level.numberOfRowsInMinuteComponent
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row)"
        } else {
            return level.titleFor(row: row)
        }
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func updateHands(){
        var shortHandRad = 2 * CGFloat.pi / 12 * CGFloat(time.hour)
        shortHandRad += 2 * CGFloat.pi / 12 / CGFloat(60) * CGFloat(time.minute)
        let longHandRad = 2 * CGFloat.pi / CGFloat(60) * CGFloat(time.minute)
        
        longHand.transform = CGAffineTransform(rotationAngle: longHandRad)
        shortHand.transform = CGAffineTransform(rotationAngle: shortHandRad)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

