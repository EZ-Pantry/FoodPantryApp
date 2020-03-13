//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
import Charts
class ViewStatisticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var totalStatsButton: UIButton!//see total statistics
    
    @IBOutlet weak var indivisualStudentButton: UIButton!//see indivisual student stats
    
    @IBOutlet weak var chooseGraphOrTextSegment: UISegmentedControl!//segment control to choose text or graph format
    
    @IBOutlet weak var studentNameLbl: UILabel!//main header
    
    @IBOutlet weak var studentIDLbl: UILabel!
    @IBOutlet weak var lastItemCheckedOutLbl: UILabel!
    @IBOutlet weak var lastDateCheckedOutLbl: UILabel!
    @IBOutlet weak var pickerField: UITextField!
    @IBOutlet weak var allergiesLbl: UILabel!
    @IBOutlet weak var totalItemsCheckedOutlbl: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var backButton: UIButton!
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()//where the choosable students names go
    var datesData: [String] = [String]()//where the dates of checking out go array
    var xAxisDataDates: [Int] = [Int]()//x axis on graph data
    var yAxisDataNumVisits: [Int] = [Int]()//y axis on graph data array
    var lineChartEntry = [ChartDataEntry]()//line Chart object array to plot points of entry
    
    @IBOutlet weak var nextButton: UIButton!
    
    var indexAtDataArray = 0;//this will be used to keep track of where at in array when back/next button is clicked
    
    var studentNames: [String] = []//indivisual names array
    
    var data : [[String: Any]] =  []
    
    var chartData : [[String: Any]] =  []
    var PantryName: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String

        yourPicker.delegate = self
        yourPicker.dataSource = self
        
        pickerField.inputView = yourPicker
        
        
        ref = Database.database().reference()
        loadStudentNames();//loading the names right when view is loaded
        
        loadInXandYAxis();
        totalStatsButton.layer.cornerRadius = 10
        totalStatsButton.clipsToBounds = true
        
        indivisualStudentButton.layer.cornerRadius = 10
        indivisualStudentButton.clipsToBounds = true
        
        backButton.layer.cornerRadius = 10
        backButton.clipsToBounds = true
        
        nextButton.layer.cornerRadius = 10
        nextButton.clipsToBounds = true
        
        pickerField.isHidden = true;
        chooseGraphOrTextSegment.isHidden = true;
        
        
    }
    
    var studentsVisitedNumberArray: [Double] = [Double]()//how many students visited indivisual array
    var itemsCheckedOutNumberAray: [Double] = [Double]()//how many items checked out indivisual array
    var editedstudentsVisitedNumberArray: [Double] = [Double]()//the last 5 days of students visited
    var editeditemsCheckedOutNumberAray: [Double] = [Double]()//the last 5 days of items checked out
    @IBAction func totalStatsButtonTapped(_ sender: UIButton) {
        pickerField.isHidden = true;
        chooseGraphOrTextSegment.isHidden = false;
        studentNameLbl.isHidden = true;
        studentIDLbl.isHidden = true;
        lastItemCheckedOutLbl.isHidden = true;
        lastDateCheckedOutLbl.isHidden = true;
        totalItemsCheckedOutlbl.isHidden = true;
        allergiesLbl.isHidden = true;
        chooseGraphOrTextSegment.selectedSegmentIndex = -1;//make sure graph is loaded initially
        
        
    }
    @IBAction func indivisualStudentButtonTapped(_ sender: UIButton) {
        //changing what is able to be seen depending on which button is clicked
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
        
        sortWhetherUser();//function which sorts out all students names only in pickerview
        
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        let getIndex = chooseGraphOrTextSegment.selectedSegmentIndex;
        if(getIndex == 0){
            //make changes depending on which segemnt control is selected
            doLineGraph();
        }
        else if(getIndex == 1){
            doTextData();
        }
    }
    
    func doLineGraph(){
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
    
    func doTextData(){
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
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        //moves one spot back in array to show previous day data
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
        if(canDisplayMap){
            //displaying what the graph shows in text format
            studentNameLbl.text = "Date: \(chartData[indexAtDataArray]["date"]! as! String)";
            studentIDLbl.text = "Students Visited: \(chartData[indexAtDataArray]["studentsVisited"]!)";
            lastItemCheckedOutLbl.text = "Items Checked out: \(chartData[indexAtDataArray]["itemsCheckedOut"]!)";
        }
        else{
            studentNameLbl.isHidden = false;
            studentNameLbl.text = "NO DATA TO DISPLAY"
        }
        
    }
    
    
    var numbers : [Double] = [1,2,3,4,5,6,7,8,9]
    
    func updateGraph(){
        //Purpose is to make the line graph composed of last five days data
        if(canDisplayMap){
            var lineChartEntry  = [ChartDataEntry]()
            var lineChartEntry2 = [ChartDataEntry]()//this is the Array that will eventually be displayed on the graph.
            //here is the for loop
            print("the count of students is: \(studentsVisitedNumberArray.count)")
            for i in 0..<studentsVisitedNumberArray.count {
                var currentNum = Double(i)
                let lastChar = String(currentNum).last!
                if(lastChar == "0"){
                    formato.stringForValue(Double(i), axis: xaxis)
                    print("i val let through: \(Double(i))")
                    let value = ChartDataEntry(x: Double(i), y: studentsVisitedNumberArray[i]) // here we set the X and Y status in a data chart entry
                    lineChartEntry.append(value) // here we add it to the data set
                    let value2 = ChartDataEntry(x: Double(i), y: itemsCheckedOutNumberAray[i]) // here we set the X and Y status in a data chart entry
                    lineChartEntry2.append(value2) // here we add it to the data set
                }
                
            }

            let line1 = LineChartDataSet(entries: lineChartEntry, label: "Students Visited") //Here we convert lineChartEntry to a LineChartDataSet
            line1.colors = [NSUIColor.blue] //Sets the color to blue
            
            let line2 = LineChartDataSet(entries: lineChartEntry2, label: "Items Checked Out") //Here we convert lineChartEntry to a LineChartDataSet
            line2.colors = [NSUIColor.red] //Sets the color to blue
            
            
            let Days = ["Day1", "Day2", "Day3", "Day4", "Day5"]
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:Days)
            chartView.xAxis.granularity = 1
            
            self.chartView.rightAxis.enabled = true
            self.chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
//            xaxis.valueFormatter = formato
//            chartView.xAxis.valueFormatter = xaxis.valueFormatter

            let data = LineChartData() //This is the object that will be added to the chart
            data.addDataSet(line1) //Adds the line to the dataSet
            data.addDataSet(line2)
            

            chartView.data = data //finally - it adds the chart data to the chart and causes an update
        }
        else{
            studentNameLbl.isHidden = false;
            studentNameLbl.text = "NO DATA TO DISPLAY"
        }
        
    }
    
    let formato:BarChartFormatter = BarChartFormatter()
    let xaxis:XAxis = XAxis()
    
    @objc(BarChartFormatter)
    public class BarChartFormatter: NSObject, IAxisValueFormatter
    {
      var months: [String]! = ["1", "2", "3", "4", "5"]

        public func stringForValue(_ value: Double, axis: AxisBase?) -> String
      {
        return months[Int(value)]
      }
    }
    
//    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
//        chartView.noDataText = "You need to provide data for the chart."
//        var dataEntries:[BarChartDataEntry] = []
//        for i in 0..<forX.count{
//           // print(forX[i])
//           // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
//            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) )
//            print(dataEntry)
//            dataEntries.append(dataEntry)
//        }
//        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Units Sold")
//        let chartData = BarChartData(dataSet: chartDataSet)
//        viewForChart.data = chartData
//        let xAxisValue = viewForChart.xAxis
//        xAxisValue.valueFormatter = axisFormatDelegate
//
//    }
    
    func sortWhetherUser(){
        print(self.data)
        print(data[0]["Admin"])
        var tempNames: [String] = []
        for i in 0..<data.count{
            print(self.data[i]["Admin"])
            if(self.data[i]["Admin"] as! String == "No"){
                tempNames.append(self.data[i]["name"] as! String)//only adding students, not admins to the visible array
            }
        }
        self.studentNames = tempNames;
        print("new student names")
        print(self.studentNames)
        pickerData = self.studentNames
    }
    func loadStudentNames(){
        let userID = Auth.auth().currentUser?.uid
        self.ref.child(self.PantryName).child("Users").observeSingleEvent(of: .value, with: { (snapshot) in

            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let first = value["First Name"] as? String ?? ""
                let last = value["Last Name"] as? String ?? ""
                let name = first + last
                let idNumber = value["ID Number"] as? String ?? ""
                let lastDateCheckedOut = value["Last Date Checked Out"] as? String ?? ""
                let lastItemCheckedOut = value["Last Item Checked Out"] as? String ?? ""
                let totalItemsCheckedOut = value["Total Items Checked Out"] as? String ?? ""
                let allergies = value["Allergies"] as? String ?? ""
                let adminValue = value["Admin"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["name": name, "idNumber": idNumber, "lastDateCheckedOut": lastDateCheckedOut, "lastItemCheckedOut": lastItemCheckedOut, "totalItemsCheckedOut": totalItemsCheckedOut, "allergies": allergies, "Admin": adminValue, "id": id])//adding each students atrributes to array
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
        self.ref.child(self.PantryName).child("Statistics").child("Total Visits").observeSingleEvent(of: .value, with: { (snapshot) in

            var tempData : [[String: Any]] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let studentsVisitedNum = value["Students Visited"] as? String ?? ""//getting students visited from firebase
                let studentsVisitedNumDouble = Double(value["Students Visited"] as? String ?? "") ?? 0//getting students visited from firebase
                let itemsCheckedOutDouble = Double(value["Items"] as? String ?? "") ?? 0//getting items checked out  from firebase
                print(studentsVisitedNumDouble)
                tempData.append(["date": key, "studentsVisited": studentsVisitedNum, "itemsCheckedOut": itemsCheckedOutDouble])
                self.studentsVisitedNumberArray.append(studentsVisitedNumDouble)
                self.itemsCheckedOutNumberAray.append(itemsCheckedOutDouble)
                c += 1
            }
            
            self.chartData = tempData
            
            print("newest data array below")
            print(self.chartData)
            
            if(self.studentsVisitedNumberArray.count == 0){
                //length is 0 means that a map cannot be formed, so will display NO DATA
                self.canDisplayMap = false;
            }
            else if(self.studentsVisitedNumberArray.count > 5){
                //since we need to display last 5 days of data, if length is larger than 5, display that last five
                self.canDisplayMap = true;
                
                
                for i in 0..<6 {
                    self.editedstudentsVisitedNumberArray[i] = self.studentsVisitedNumberArray[self.studentsVisitedNumberArray.count-(i+1)]
                        self.editeditemsCheckedOutNumberAray[i] = self.itemsCheckedOutNumberAray[self.itemsCheckedOutNumberAray.count-(i+1)]
                }
                
            }
            
        })
        
    }
    
    var canDisplayMap = true;//boolean to make sure that map has data to be displayed
    
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
        var studentNameChosen = pickerData[row];
        for i in 0..<data.count{
            if(self.data[i]["name"] as! String == studentNameChosen){
                //displaying corresponding data to that student
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
        //go back to selection page for admin controls
        dismiss(animated: true, completion: nil)
    }
    

}



