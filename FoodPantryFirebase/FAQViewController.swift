//
//  FAQViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 3/22/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        loadQuestionsAndAnswers();
        
    }
    
    func loadQuestionsAndAnswers(){
        let items = [FAQItem(question: "I am not able to checkout. Why?", answer: "The administrators at your food pantry have disabled checkout. If you think this may be an error, feel free to contact your administrator."),
        FAQItem(question: "I reset my password, but don’t see the reset password email?", answer: "Be sure to check your spam and trash folder."),
        FAQItem(question: "Who determined whether an item was healthy or not?", answer: "The administrators at your food pantry have decided whether an item is healthy or not."),
        FAQItem(question: "Unanswered question?", answer: "Feel free to contact the app developers!")]//questions & answers

        let faqView = FAQView(frame: view.frame, title: "Top Questions", items: items)//set the title
        view.addSubview(faqView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
