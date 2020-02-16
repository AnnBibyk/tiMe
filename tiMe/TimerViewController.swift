//
//  ViewController.swift
//  tiMe
//
//  Created by Anna Bibyk on 15.02.2020.
//  Copyright © 2020 Anna Bibyk. All rights reserved.
//

import UIKit
import CoreData

enum TimerState: Int32 {
    case inactive
    case active
    case paused
}

class TimerViewController: UIViewController {
    
    var timerState = TimerState.inactive
    var timerInterval : Double?
    var startDate = Date()
    var timer : Timer?
    
    var isTimerActive: Bool = false
    var isCellOpen: Bool = false
    
    var timeList: [NSManagedObject] = []
    let textView = UITextView(frame: CGRect.zero)
    var noteToTime = ""
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timesTableView: UITableView!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var timerScreenView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = "00:00:00"
        timeLabel.textColor = .gray
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerMethod), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observerMethod), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // tap gesture added
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapToStartPauseTimer))
        singleTap.numberOfTapsRequired = 1
        timeLabel.addGestureRecognizer(singleTap)
        
        // double tap gesture added
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapToFinishTimer))
        doubleTap.numberOfTapsRequired = 2
        timeLabel.addGestureRecognizer(doubleTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TimeData.fetchTimerListData(timeList: &timeList)
    }
    
    @objc func observerMethod(notification: NSNotification) {
        if notification.name == UIApplication.didEnterBackgroundNotification {
            print("Background")
            
            timer?.invalidate()
        } else if notification.name == UIApplication.didBecomeActiveNotification {
            print("Foreground")
            
            if timerState == .active {
                updateStopwatch()
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateStopwatch), userInfo: nil, repeats: true);
            }
        }
    }
    
    // MARK: - Startint or Pausing the timer
    
    @objc private func tapToStartPauseTimer() {
        if !isTimerActive {
            if timerState == .inactive {
                print("Start")
                startDate = Date()
    
            } else if timerState == .paused {
                print("Continue")
                startDate = Date().addingTimeInterval(-timerInterval!)
            }
            timerState = .active
            
            timeLabel.textColor = .black
            updateStopwatch()
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateStopwatch), userInfo: nil, repeats: true);
            
        } else {
            print("Pause")
            
            timerInterval = floor(-startDate.timeIntervalSinceNow)
            timeLabel.textColor = .gray
            
            timerState = .paused
            timer?.invalidate()
        }
        isTimerActive = !isTimerActive
    }
    
    @objc private func updateStopwatch() {
        
        let interval = -Double(startDate.timeIntervalSinceNow) + 0.01
        let flooredInterval = Int(floor(interval))
        
        let hours = flooredInterval / 3600
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        
        let minutes = (flooredInterval / 60) % 60
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        let seconds = (flooredInterval % 60)
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        timeLabel.text = "\(hoursString):\(minutesString):\(secondsString)"
        
    }
    
    // MARK: - Stopping the timer
    
    @objc private func tapToFinishTimer() {
        print("Stop")
        
        timer?.invalidate()
        isTimerActive = false
        alertWindowConfig()
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        print("Reset")
        
        timeLabel.text = "00:00:00"
        startDate = Date()
        timerInterval = 0.0
    }
    
    // MARK: - Alert window
    
    private func alertWindowConfig() {
        let alertController = UIAlertController(title: "Note \n\n\n\n\n", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
        }
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            self.noteToTime = self.textView.text
            alertController.view.removeObserver(self, forKeyPath: "bounds")
            
            TimeData.saveNewTimeInList(timeList: &self.timeList, noteToTime: self.noteToTime, timer: self.timeLabel.text!)
            self.timesTableView.reloadData()
            self.timeLabel.text = "00:00:00"
            self.timerState = .inactive
        }
        alertController.addAction(saveAction)
        
        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        textView.backgroundColor = UIColor.white
        textView.text = ""
        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        textView.delegate = self
        hideKeyboardWhenTappedAround()
        alertController.view.addSubview(self.textView)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 8
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 96
                
                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
    
    // MARK: - Clear Button
    
    @IBAction func clearAllListButton(_ sender: UIBarButtonItem) {
        print("Clear")
        
        if timeList.isEmpty {
            let alert = UIAlertController(title: "The list is already empty", message: "There is nothing to be cleared", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        } else {
            
            let alert = UIAlertController(title: "Clearing the list", message: "Are you sure you want to clear all time data?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                TimeData.clearTimeListData()
                self.timeList.removeAll()
                self.timesTableView.reloadData()
            }))
            self.present(alert, animated: true)
        }
    }
}
