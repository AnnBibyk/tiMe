//
//  Etensions.swift
//  tiMe
//
//  Created by Anna Bibyk on 16.02.2020.
//  Copyright © 2020 Anna Bibyk. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Table View configuration

extension TimerViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! TimeTableViewCell
        let entity = timeList[indexPath.row]
        
        cell.timeNoteLabel.text = entity.value(forKey: "message") as? String
        cell.timeLabel.text = entity.value(forKey: "time") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = timeList[indexPath.row]
            
            managedContext.delete(entity)
            
            if managedContext.hasChanges {
                do {
                    try managedContext.save()
                }
                catch{
                    fatalError("Fail to save content \(error)");
                }
            }
            timeList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension TimerViewController: UITextViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Character limits
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let note = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        return note.count < 255
    }
    
    
}
