//
//  FAQViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/22/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
class FAQViewController: UIViewController {

    var ref: DatabaseReference!//reference to the database
    
    var stringOfFAQData : [[String: Any]] =  []//quesitons and answers arary
    var alert = LoadingBar()
    var PantryName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()

        PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        let myGroup = DispatchGroup()
            
        alert.showLoadingAlert()
        myGroup.enter()
            self.retreiveQRTextFromFirebase(callback: {(success, QRText)-> Void in
             if(success) {
                //do creation of QR
                print(self.stringOfFAQData)
                self.loadQuestionsAndAnswers();
                myGroup.leave()
             } else {
                RequestError().showError()
            }
            
         })
        
        myGroup.notify(queue: .main) {
            self.alert.hideLoadingAlert()
        }
        
        
    }
    
    func retreiveQRTextFromFirebase(callback: @escaping (_ success: Bool,_ location: String)-> Void) {
        ref.child(PantryName).child("FAQ Page").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            var tempData : [[String: Any]] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let faqQuestion = value["Question"] as? String ?? ""
                let faqAnswer = value["Answer"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["question": faqQuestion, "answer": faqAnswer])//adding each students atrributes to array
                c += 1
            }
            
            self.stringOfFAQData = tempData;
            
            callback(true, "Done")
        // ...
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
            callback(false, "")
        }
    }
    
    var items: [FAQItem] = []
    func loadQuestionsAndAnswers(){
        for x in 0..<stringOfFAQData.count{
            let item = FAQItem(question: stringOfFAQData[x]["question"] as! String, answer: stringOfFAQData[x]["answer"] as! String)//add the question and answer to their own containers
            items.append(item)
        }

        let faqView = FAQView(frame: view.frame, title: "Top Questions", items: items)//set the title for the FAQ page
        
        view.addSubview(faqView)
    }

}
