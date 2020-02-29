//
//  ViewStatisticsViewController.swift
//  FoodPantryFirebase
//
//  Created by Rayaan Siddiqi on 2/26/20.
//  Copyright © 2020 Rayaan Siddiqi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
import Charts
class ViewStatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var totalStatsButton: UIButton!
    @IBOutlet weak var indivisualStudentButton: UIButton!
    
    @IBOutlet weak var chooseGraphOrTextSegment: UISegmentedControl!
    
    @IBOutlet weak var studentNameLbl: UILabel!
    
    @IBOutlet weak var studentIDLbl: UILabel!
    @IBOutlet weak var lastItemCheckedOutLbl: UILabel!
    @IBOutlet weak var lastDateCheckedOutLbl: UILabel!
    @IBOutlet weak var pickerField: UITextField!
    @IBOutlet weak var allergiesLbl: UILabel!
    @IBOutlet weak var totalItemsCheckedOutlbl: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    var ref: DatabaseReference!
    
    @IBOutlet weak var backButton: UIButton!
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()
    var datesData: [String] = [String]()
    var xAxisDataDates: [Int] = [Int]()
    var yAxisDataNumVisits: [Int] = [Int]()
    var lineChartEntry = [ChartDataEntry]()
    
    @IBOutlet weak var nextButton: UIButton!
    
    var indexAtDataArray = 0;
    
    var studentNames = ["Mac N Cheese", "Penne Pasta", "Granola Bars", "Veggie Soup"]
    
    var data : [[String: Any]] =  [
        ["name": "Lebron James","id": "821209", "isAdmin": "No", "totalCheckedOut": "2", "lastItemCheckedOut": "a", "LastDateCheckedOut": "no", "allergies": "grass"],
        ["name": "Cheese Grader","id": "821209", "isAdmin": "No", "totalCheckedOut": "2", "lastItemCheckedOut": "a", "LastDateCheckedOut": "no", "allergies": "grass"],
        ["name": "Kenton James","id": "821209", "isAdmin": "N", "totalCheckedOut": "2", "lastItemCheckedOut": "a", "LastDateCheckedOut": "no", "allergies": "grass"]
        
    ]
    
    var chartData : [[String: Any]] =  [
        ["date": "26-2-20","studentsVisited": "10"],
        ["date": "27-2-20", "studentsVisited": "10"]
        
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        pickerField.inputView = yourPicker
        
        ref = Database.database().reference()
        loadStudentNames();
        loadInXandYAxis();
        totalStatsButton.layer.cornerRadius = 10
        totalStatsButton.clipsToBounds = true
        
        indivisualStudentButton.layer.cornerRadius = 10
        indivisualStudentButton.clipsToBounds = true
        
        backButton.layer.cornerRadius = 10
        backButton.clipsToBounds = true
        
        nextButton.layer.cornerRadius = 10
        nextButton.clipsToBounds = true
    }
    
    var studentsVisitedNumberArray: [Double] = [Double]()
    @IBAction func totalStatsButtonTapped(_ sender: UIButton) {
        pickerField.isHidden = true;
        chooseGraphOrTextSegment.isHidden = false;
        studentNameLbl.isHidden = true;
        studentIDLbl.isHidden = true;
        lastItemCheckedOutLbl.isHidden = true;
        lastDateCheckedOutLbl.isHidden = true;
        totalItemsCheckedOutlbl.isHidden = true;
        allergiesLbl.isHidden = true;
        
        
    }
    @IBAction func indivisualStudentButtonTapped(_ sender: UIButton) {
        pickerField.isHidden = false;
        chooseGraphOrTextSegment.isHidden = true;
        chartView.isHidden = true;
        studentNameLbl.isHidden = false;
        studentNameLbl.text = ""
        studentIDLbl.isHidden = false;
        studentIDLbl.text = ""
        lastItemCheckedOutLbl.isHidden = false;
        lastItemCheckedOutLbl.text = ""
        lastDateCheckedOutLbl.isHidden = false;
        totalItemsCheckedOutlbl.isHidden = false;
        allergiesLbl.isHidden = false;
        
        sortWhetherUser();
        
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        let getIndex = chooseGraphOrTextSegment.selectedSegmentIndex;
        if(getIndex == 0){
            backButton.isHidden = true;
            nextButton.isHidden = true;
            updateGraph()
            chartView.isHidden = false;
            studentNameLbl.isHidden = true;
            studentIDLbl.isHidden = true;
            lastItemCheckedOutLbl.isHidden = true;
            lastDateCheckedOutLbl.isHidden = true;
            totalItemsCheckedOutlbl.isHidden = true;
            allergiesLbl.isHidden = true;
        }
        else if(getIndex == 1){
            backButton.isHidden = false;
            nextButton.isHidden = false;
            chartView.isHidden = true;
            
            studentNameLbl.isHidden = false;
            studentNameLbl.text = ""
            studentIDLbl.isHidden = false;
            studentIDLbl.text = ""
            lastItemCheckedOutLbl.isHidden = false;
            lastItemCheckedOutLbl.text = ""
            //display date at top and students visited nd number of items checked out at bottom
            backButton.isHidden = true;
            print(chartData.count)
            showCorrespondingTextStatisticsData();
            //use \n
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        checkIfAvailableBack();
        showCorrespondingTextStatisticsData();
        
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        checkIfAvialableNext();
        showCorrespondingTextStatisticsData();
    }
    
    func checkIfAvialableNext(){
        //purpose to check if you can advance ahead
        indexAtDataArray += 1;
        if(indexAtDataArray-1 != -1 && indexAtDataArray+1 != chartData.count){
            nextButton.isHidden = false;
            backButton.isHidden = false;
            
        }
        else if(indexAtDataArray-1 != -1 && indexAtDataArray+1 == chartData.count){
            nextButton.isHidden = true;
            backButton.isHidden = false;
            
        }
        else if(indexAtDataArray-1 == -1){
            nextButton.isHidden = false;
            backButton.isHidden = true;
        }
        print("inside the next: \(indexAtDataArray)")
    }
    
    func checkIfAvailableBack(){
        indexAtDataArray -= 1;
        if(indexAtDataArray+1 != chartData.count && indexAtDataArray-1 != -1){
            nextButton.isHidden = false;
            backButton.isHidden = false;
        }
        else if(indexAtDataArray+1 != chartData.count && indexAtDataArray-1 == -1){
            nextButton.isHidden = false;
            backButton.isHidden = true;
        }
        else if(indexAtDataArray+1 == chartData.count){
            nextButton.isHidden = true;
            backButton.isHidden = false;
        }
        print("inside the next: \(indexAtDataArray)")
    }
    
    func showCorrespondingTextStatisticsData(){
        studentNameLbl.text = "Date: \(chartData[indexAtDataArray]["date"]! as! String)";
        studentIDLbl.text = "Students Visited: \(chartData[indexAtDataArray]["studentsVisited"]!)";
        lastItemCheckedOutLbl.text = "Items Checked out: \(chartData[indexAtDataArray]["itemsCheckedOut"]!)";
    }
    
    
    var numbers : [Double] = [1,2,3,4,5,6,7,8,9]
    
    func updateGraph(){
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        //here is the for loop
        for i in 0..<studentsVisitedNumberArray.count {
            var currentNum = Double(i)
            let lastChar = String(currentNum).last!
            if(lastChar == "0"){
                print("i val let through: \(Double(i))")
                let value = ChartDataEntry(x: Double(i), y: studentsVisitedNumberArray[i]) // here we set the X and Y status in a data chart entry
                lineChartEntry.append(value) // here we add it to the data set
            }
            
        }

        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Students Visited") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the color to blue
        
        self.chartView.rightAxis.enabled = true
        self.chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom

        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        

        chartView.data = data //finally - it adds the chart data to the chart and causes an update
        chartView.chartDescription?.text = "Students visits per day " // Here we set the description for the graph
    }
    
    func sortWhetherUser(){
        print(self.data)
        print(data[0]["Admin"])
        var tempNames: [String] = []
        for i in 0..<data.count{
            print(self.data[i]["Admin"])
            if(self.data[i]["Admin"] as! String == "No"){
                print("checknboi")
                tempNames.append(self.data[i]["name"] as! String)
            }
        }
        self.studentNames = tempNames;
        print("new student names")
        print(self.studentNames)
        pickerData = self.studentNames
    }
    func loadStudentNames(){
        let userID = Auth.auth().currentUser?.uid
        self.ref.child("Conant High School").child("Users").observeSingleEvent(of: .value, with: { (snapshot) in

            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let name = value["Name"] as? String ?? ""
                let idNumber = value["ID Number"] as? String ?? ""
                let lastDateCheckedOut = value["Last Date Checked Out"] as? String ?? ""
                let lastItemCheckedOut = value["Last Item Checked Out"] as? String ?? ""
                let totalItemsCheckedOut = value["Total Items Checked Out"] as? String ?? ""
                let allergies = value["Allergies"] as? String ?? ""
                let adminValue = value["Admin"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["name": name, "idNumber": idNumber, "lastDateCheckedOut": lastDateCheckedOut, "lastItemCheckedOut": lastItemCheckedOut, "totalItemsCheckedOut": totalItemsCheckedOut, "allergies": allergies, "Admin": adminValue, "id": id])
                tempNames.append(name)
                c += 1
            }
            
            self.data = tempData
            self.studentNames = tempNames
            
            print("data array below")
            print(self.data)
            print("studentNames below")
            print(self.studentNames)
            
        })
                
        
    }
    
    func loadInXandYAxis(){
        self.ref.child("Conant High School").child("Statistics").child("Total Visits").observeSingleEvent(of: .value, with: { (snapshot) in

            var tempData : [[String: Any]] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let studentsVisitedNum = value["Students Visited"] as? String ?? ""
                let studentsVisitedNumDouble = Double(value["Students Visited"] as? String ?? "") ?? 0
                let itemsCheckedOutDouble = Double(value["Items"] as? String ?? "") ?? 0
                print(studentsVisitedNumDouble)
                tempData.append(["date": key, "studentsVisited": studentsVisitedNum, "itemsCheckedOut": itemsCheckedOutDouble])
                self.studentsVisitedNumberArray.append(studentsVisitedNumDouble)
                c += 1
            }
            
            self.chartData = tempData
            
            print("newest data array below")
            print(self.chartData)
            
        })
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerField.text = pickerData[row]
//        studentNameLbl
        var studentNameChosen = pickerData[row];
        for i in 0..<data.count{
            if(self.data[i]["name"] as! String == studentNameChosen){
                var studentName = self.data[i]["name"]
                var studentIDNumber = self.data[i]["idNumber"]
                var lastDateCheckedOut = self.data[i]["lastDateCheckedOut"]
                var lastItemCheckedOut = self.data[i]["lastItemCheckedOut"]
                var totalItemsCheckedOut = self.data[i]["totalItemsCheckedOut"]
                var allergies = self.data[i]["allergies"]
                
                studentNameLbl.text = studentName! as! String;
                studentIDLbl.text = "ID: \(studentIDNumber!)"
                lastItemCheckedOutLbl.text = "Last Item Checked Out: \(lastItemCheckedOut!)"
                lastDateCheckedOutLbl.text = "Last Date Checked Out: \(lastDateCheckedOut!)"
                totalItemsCheckedOutlbl.text = "Total Items Checked Out: \(totalItemsCheckedOut!)"
                allergiesLbl.text = "Allergies: \(allergies!)"
            }
        }
        
    }
    
    @IBAction func dismissBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
