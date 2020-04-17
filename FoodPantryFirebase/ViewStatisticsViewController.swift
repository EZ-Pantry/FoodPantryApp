//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import UIKit
import FirebaseUI
import FirebaseDatabase
import Charts
class ViewStatisticsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var chooseGraphOrTextSegment: UISegmentedControl!//segment control to choose text or graph format
    
    @IBOutlet weak var chartView: LineChartView!
            

    var ref: DatabaseReference!
    
    let yourPicker = UIPickerView()
    var pickerData: [String] = [String]()//where the choosable students names go
    var datesData: [String] = [String]()//where the dates of checking out go array
    var xAxisDataDates: [Int] = [Int]()//x axis on graph data
    var emptyStringArray: [String] = [String]()
    var yAxisDataNumVisits: [Int] = [Int]()//y axis on graph data array
    var lineChartEntry = [ChartDataEntry]()//line Chart object array to plot points of entry
    
    
    var indexAtDataArray = 0;//this will be used to keep track of where at in array when back/next button is clicked
    
    var studentNames: [String] = []//indivisual names array
    
    var data : [[String: Any]] =  []
    var itemsCheckedOutData : [[String: Any]] =  []
    
    var itemsCheckedOutDoubleArray : [Double] = []
    var itemsCheckedOutStringNames : [String] = []
    var chartData : [[String: Any]] =  []
    var PantryName: String = ""

    @IBOutlet weak var itemsBarChartView: BarChartView!
    
    @IBOutlet var infoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsBarChartView.delegate = self
        self.PantryName = UserDefaults.standard.object(forKey:"Pantry Name") as! String
        
        
        ref = Database.database().reference()
        loadStudentNames();//loading the names right when view is loaded
        
        loadInXandYAxis();
        loadItemsData();
      
        
       
        chooseGraphOrTextSegment.isHidden = false;
       
        chooseGraphOrTextSegment.selectedSegmentIndex = -1;//make sure graph is loaded initially
        
        infoView.layer.borderColor = UIColor.black.cgColor
        infoView.layer.borderWidth = 7.0
        infoView.layer.cornerRadius = chartView.frame.height / 8
        infoView.layer.backgroundColor = UIColor(red: 192/255, green: 177/255, blue: 192/255, alpha: 1).cgColor
    }
    
    
    var studentsVisitedNumberArray: [Double] = [Double]()//how many students visited indivisual array
    var itemsCheckedOutNumberAray: [Double] = [Double]()//how many items checked out indivisual array
    var editedstudentsVisitedNumberArray: [Double] = [Double]()//the last 5 days of students visited
    var editeditemsCheckedOutNumberAray: [Double] = [Double]()//the last 5 days of items checked out
    @IBAction func totalStatsButtonTapped(_ sender: UIButton) {
        chooseGraphOrTextSegment.isHidden = false;
        chooseGraphOrTextSegment.selectedSegmentIndex = -1;//make sure graph is loaded initially
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        itemsBarChartView.delegate = self
        print("delegate here")
        print(itemsBarChartView.delegate)
        loadStudentNames();
        chooseGraphOrTextSegment.isHidden = false;
        chartView.isHidden = true;
        itemsBarChartView.isHidden = true;
        
    }
    @IBAction func indivisualStudentButtonTapped(_ sender: UIButton) {
        //changing what is able to be seen depending on which button is clicked
        chooseGraphOrTextSegment.isHidden = true;
        chartView.isHidden = true;
        itemsBarChartView.isHidden = true;
        sortWhetherUser();//function which sorts out all students names only in pickerview
        
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        let getIndex = chooseGraphOrTextSegment.selectedSegmentIndex;
        if(getIndex == 0){
            //make changes depending on which segemnt control is selected
            doLineGraph();
        }
        else if(getIndex == 1){
            self.performSegue(withIdentifier: "toCalendar", sender: self)
        }
        else if(getIndex == 2){
            doBarGraph();
        }
//        else if(getIndex == 3){
//            doBarGraph();
//        }
    }
    
    func doBarGraph(){
        setChartForItemsData()
        chartView.isHidden = true;
        itemsBarChartView.isHidden = false;
        
    }
    var months: [String]!
    func setChartForItemsData(){
        setChart(values: itemsCheckedOutDoubleArray)
    }
    
    
    var arrayOfAllItemsData: [BarChartDataSet]!
    func setChart(values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<values.count {
          let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
          dataEntries.append(dataEntry)
        }

        //need to set each item with indivisual marker
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Items in Food Pantry(Click bars to see more data)")//each column represnents a food item checked out number of times
        
        chartDataSet.colors = [UIColor.init(displayP3Red: 70/255, green: 50/255, blue: 31/255, alpha: 1)]
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        //sets x axis values
        for x in 0..<itemsCheckedOutStringNames.count{
            emptyStringArray.append(" ")//to make the x axis free of any random numbers
        }
        itemsBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: emptyStringArray)
        itemsBarChartView.xAxis.granularity = 1
        
        self.itemsBarChartView.rightAxis.enabled = true
        self.itemsBarChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        itemsBarChartView.data = chartData
        
        itemsBarChartView.setVisibleXRangeMaximum(5)//show 5 at a time-makes the bar chart scrollable
        
        itemsBarChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //display item name here when clicked
        var entryYValSelected = entry.y
        
        for x in 0..<itemsCheckedOutData.count{
            if(entryYValSelected == itemsCheckedOutDoubleArray[x]){
                //when a bar is clicked, a pop over with little info about that item appears
                print("item found")
                print(itemsCheckedOutStringNames[x])
                foodNameClicked = itemsCheckedOutStringNames[x]
                foodImageClicked = itemsCheckedOutData[x]["itemImage"] as! String
                foodCheckedOutClicked = itemsCheckedOutData[x]["numCheckedOut"] as! String
                print(foodImageClicked)
                print(foodCheckedOutClicked)
                print("occurirnghere")
                self.performSegue(withIdentifier: "toItemMiniPopOver", sender: self)
            }
        }
        
        
    }
    
    var foodNameClicked = ""//the item name
    var foodImageClicked = ""//image URL
    var foodCheckedOutClicked = ""//number of that item checked out
    
    //segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //send data to other VC
        if segue.identifier == "toItemMiniPopOver"{
            let destinationVC = segue.destination as? popUpFromBarChartViewController
            destinationVC?.name = foodNameClicked
            destinationVC?.checkedout = foodCheckedOutClicked
            destinationVC?.image = foodImageClicked


        }
    }


    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("chartValueNothingSelected")
    }
    

    
    func doLineGraph(){
        updateGraph()
        chartView.isHidden = false;
        itemsBarChartView.isHidden = true;
    }
    
    func doTextData(){
        chartView.isHidden = true;
        itemsBarChartView.isHidden = true;
        //display date at top and students visited nd number of items checked out at bottom
        print(chartData.count)
        showCorrespondingTextStatisticsData();
    }
    
    
    func showCorrespondingTextStatisticsData(){
        if(canDisplayMap){
            //displaying what the graph shows in text format
        }
        else{
          
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
            for i in 0..<editeditemsCheckedOutNumberAray.count {
                var currentNum = Double(i)
                let lastChar = String(currentNum).last!
                if(lastChar == "0"){
//                    formato.stringForValue(Double(i), axis: xaxis)
                    print("i val let through: \(Double(i))")
                    let value = ChartDataEntry(x: Double(i), y: editedstudentsVisitedNumberArray[i]) // here we set the X and Y status in a data chart entry
                    lineChartEntry.append(value) // here we add it to the data set
                    let value2 = ChartDataEntry(x: Double(i), y: editeditemsCheckedOutNumberAray[i]) // here we set the X and Y status in a data chart entry
                    lineChartEntry2.append(value2) // here we add it to the data set
                }
                
            }

            let line1 = LineChartDataSet(entries: lineChartEntry, label: "Students Visited") //Here we convert lineChartEntry to a LineChartDataSet
            line1.colors = [NSUIColor.init(red: 0, green: 92/255, blue: 111/255, alpha: 1)] //Sets the color to blue
            
            let line2 = LineChartDataSet(entries: lineChartEntry2, label: "Items Checked Out") //Here we convert lineChartEntry to a LineChartDataSet
            line2.colors = [NSUIColor.init(red: 241/255, green: 143/255, blue: 0, alpha: 1)] //Sets the color to blue
            
            
            let Days = ["5 Days", "4 Days", "3 Days", "2 Days", "1 Day"]
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:Days)
            chartView.xAxis.granularity = 1
            chartView.xAxis.labelWidth = 5
            
            self.chartView.rightAxis.enabled = true
            self.chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
            self.chartView.chartDescription?.text = "Past 5 Days Ago Data"
//            xaxis.valueFormatter = formato
//            chartView.xAxis.valueFormatter = xaxis.valueFormatter

            let data = LineChartData() //This is the object that will be added to the chart
            data.addDataSet(line1) //Adds the line to the dataSet
            data.addDataSet(line2)
            

            chartView.data = data //finally - it adds the chart data to the chart and causes an update
        }
        
    }
    
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
    
    func loadItemsData(){
        self.ref.child(self.PantryName).child("Inventory").child("Food Items").observeSingleEvent(of: .value, with: { (snapshot) in

            var tempData : [[String: Any]] = []
            var tempNames: [String] = []
            var c: Int = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value: [String: Any] = snap.value as! [String : Any]
                
                let itemName = value["Name"] as? String ?? ""
                let itemImage = value["URL"] as? String ?? ""
                let checkedOutString = value["Checked Out"] as? String ?? ""
                let checkedOutDouble = Double(value["Checked Out"] as? String ?? "") ?? 0
                let id = String(c)
                
                tempData.append(["itemName": itemName, "numCheckedOut": checkedOutString, "itemImage": itemImage])//adding each students atrributes to array
                self.itemsCheckedOutDoubleArray.append(checkedOutDouble)
                self.itemsCheckedOutStringNames.append(itemName)
                c += 1
            }
            
            self.itemsCheckedOutData = tempData
            
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
                
        
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
                let name = first + " " + last
                let idNumber = value["ID Number"] as? String ?? ""
                let lastDateCheckedOut = value["Last Date Checked Out"] as? String ?? ""
                let lastItemCheckedOut = value["Last Item Checked Out"] as? String ?? ""
                let totalItemsCheckedOut = value["Total Items Checked Out"] as? String ?? ""
                let allergies = value["Allergies"] as? String ?? ""
                let adminValue = value["Admin"] as? String ?? ""
                let userEmail = value["Email Address"] as? String ?? ""
                let userPassword = value["Password"] as? String ?? ""
                let id = String(c)
                
                tempData.append(["name": name, "idNumber": idNumber, "lastDateCheckedOut": lastDateCheckedOut, "lastItemCheckedOut": lastItemCheckedOut, "totalItemsCheckedOut": totalItemsCheckedOut, "allergies": allergies, "Admin": adminValue, "Email": userEmail, "Password": userPassword, "id": id])//adding each students atrributes to array
                tempNames.append(name)
                c += 1
            }
            
            self.data = tempData
            self.studentNames = tempNames
            
            
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
                
        
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
                //since we need to display last 5 days of data, if length is larger than 5, display that last five days
                self.canDisplayMap = true;
                for i in 0..<5 {
                    self.editedstudentsVisitedNumberArray.append( self.studentsVisitedNumberArray[self.studentsVisitedNumberArray.count-(i+1)])
                    self.editeditemsCheckedOutNumberAray.append( self.itemsCheckedOutNumberAray[self.itemsCheckedOutNumberAray.count-(i+1)])
                    self.editedstudentsVisitedNumberArray.reverse()//make sure order is oldest data to newest
                    self.editeditemsCheckedOutNumberAray.reverse()
                }
                
            }
            
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
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
        if(pickerData.count == 0) {
            return
        }
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
                var studentEmail = self.data[i]["Email"]
                var studentPassword = self.data[i]["Password"]
            }
        }
        
    }
    
    @IBAction func dismissBack(_ sender: UIButton) {
        //go back to selection page for admin controls
        dismiss(animated: true, completion: nil)
    }
    
    
    

}

