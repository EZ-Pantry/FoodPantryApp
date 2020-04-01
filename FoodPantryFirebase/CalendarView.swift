//  Copyright © 2020 Ashay Parikh, Rayaan Siddiqi. All rights reserved.


import Foundation
import UIKit
import FirebaseUI
import FirebaseDatabase
struct Colors {
    static var darkGray = #colorLiteral(red: 0.3764705882, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
    static var darkRed = #colorLiteral(red: 0.5019607843, green: 0.1529411765, blue: 0.1764705882, alpha: 1)
}

struct Style {
    static var bgColor = UIColor.white
    static var monthViewLblColor = UIColor.white
    static var monthViewBtnRightColor = UIColor.white
    static var monthViewBtnLeftColor = UIColor.white
    static var activeCellLblColor = UIColor.white
    static var activeCellLblColorHighlighted = UIColor.black
    static var weekdaysLblColor = UIColor.white
    
    static func themeDark(){
        bgColor = Colors.darkGray
        monthViewLblColor = UIColor.white
        monthViewBtnRightColor = UIColor.white
        monthViewBtnLeftColor = UIColor.white
        activeCellLblColor = UIColor.white
        activeCellLblColorHighlighted = UIColor.black
        weekdaysLblColor = UIColor.white
    }
    
    static func themeLight(){
        bgColor = UIColor.white
        monthViewLblColor = UIColor.black
        monthViewBtnRightColor = UIColor.black
        monthViewBtnLeftColor = UIColor.black
        activeCellLblColor = UIColor.black
        activeCellLblColorHighlighted = UIColor.white
        weekdaysLblColor = UIColor.black
    }
}

class CalenderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MonthViewDelegate {
    
    var ref: DatabaseReference!
    
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    
    var fullyFormatedDate: String = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        ref = Database.database().reference()
        
        loadInFirebaseTextDataAboutStatistics();
        initializeView()
        monthView.btnLeft.isEnabled = true;
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"//in month/day/year format
        //        MM-dd-yyyy- no need
        self.fullyFormatedDate = formatter.string(from:NSDate.init(timeIntervalSinceNow: 0) as Date)//the current date in literal format
    }
    
    convenience init(theme: MyTheme) {
        self.init()
        
        if theme == .dark {
            Style.themeDark()
        } else {
            Style.themeLight()
        }
        
        initializeView()
    }
    
    func changeTheme() {
        //change from dark theme if desired
        myCollectionView.reloadData()
        
        monthView.lblName.textColor = Style.monthViewLblColor
        monthView.btnRight.setTitleColor(Style.monthViewBtnRightColor, for: .normal)
        monthView.btnLeft.setTitleColor(Style.monthViewBtnLeftColor, for: .normal)
        
        for i in 0..<7 {
            (weekdaysView.myStackView.subviews[i] as! UILabel).textColor = Style.weekdaysLblColor
        }
    }
    
    func initializeView() {
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        currentYear = Calendar.current.component(.year, from: Date())
        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth=getFirstWeekDay()
        
        //for leap years, make february month of 29 days
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
        //end
        
        presentMonthIndex=currentMonthIndex
        presentYear=currentYear
        
        setupViews()
        
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(dateCVCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("called")
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dateCVCell
        cell.backgroundColor=UIColor.clear
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden=true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth+2
            print(calcDate)
            cell.isHidden=false
            cell.lbl.text="\(calcDate)"
            cell.isUserInteractionEnabled=true//all of the dates can be clicked
            cell.lbl.textColor = Style.activeCellLblColor
            var currentMonthString = ""
             var currentDayString = ""
             if(currentMonthIndex<10){
                 //to make sure formate is correct add zero before dates which dont
                 currentMonthString = "0" + String(currentMonthIndex)
             }
             else{
                 currentMonthString = String(currentMonthIndex)
             }
                         
             if(Int(cell.lbl.text!)!<10){
                 currentDayString = "0" + cell.lbl.text!
             }
             else{
                 currentDayString = cell.lbl.text!;
             }
             fullyCorrectedDate = currentMonthString + "-" + currentDayString + "-" + String(currentYear)//date which user has clicked on fully formatted
            print(fullyCorrectedDate)
            if(fullyFormatedDate == fullyCorrectedDate){
                cell.backgroundColor=Colors.darkRed
            }
//            cell?.backgroundColor=Colors.darkRed
        }
        return cell
    }
    
    var dateClicked = ""
    var fullyCorrectedDate = ""
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //WHERE ALL HANDLING SHALL OCCUR
        let cell=collectionView.cellForItem(at: indexPath)
        var otherClicked = cell?.subviews[1] as! UILabel;
        for x in 0..<numOfDaysInMonth[currentMonthIndex-1]{
            let cell=collectionView.cellForItem(at: [0, x])
            let lbl = cell?.subviews[1] as! UILabel
            if(lbl.text! != otherClicked.text){
                cell!.backgroundColor=Colors.darkGray
            }
        }
        cell?.backgroundColor=Colors.darkRed
        let lbl = cell?.subviews[1] as! UILabel
        lbl.textColor=UIColor.white
        print("date day below")
        print(lbl.text)
        dateClicked = lbl.text!
        
        var currentMonthString = ""
        var currentDayString = ""
        if(currentMonthIndex<10){
            //to make sure formate is correct add zero before dates which dont
            currentMonthString = "0" + String(currentMonthIndex)
        }
        else{
            currentMonthString = String(currentMonthIndex)
        }
       
        
        if(Int(dateClicked)!<10){
            currentDayString = "0" + dateClicked
        }
        else{
            currentDayString = dateClicked;
        }
        fullyCorrectedDate = currentMonthString + "-" + currentDayString + "-" + String(currentYear)//date which user has clicked on fully formatted
        print("date fully done: \(fullyCorrectedDate)")
        determineWhetherDateContainsData();
        //dont disable any buttons
    }
    
    var dataWasFound = false;
    func determineWhetherDateContainsData(){
        dataWasFound = false;
        let whiteBgButton = UIButton()
        var midY = frame.height / 2
        var midX = frame.width / 2
        whiteBgButton.backgroundColor =  UIColor(red: 252/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1.0)
        whiteBgButton.frame = CGRect(x: midX-175, y: midY + 200, width: 350, height: 350)//background behind labels
        addSubview(whiteBgButton)
        let itemsCheckedOutLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let studentsVisitedLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        itemsCheckedOutLbl.textColor = UIColor.white;
        studentsVisitedLbl.textColor = UIColor.white;
        itemsCheckedOutLbl.font = UIFont.boldSystemFont(ofSize: 16)
        studentsVisitedLbl.font = UIFont.boldSystemFont(ofSize: 16)
        for x in 0..<dataLoadedIn.count{
            //comparing the date which clicked to ones available in firebase
            var dateLoadedFromFirebaseDataSet = dataLoadedIn[x]["date"] as! String?
            print("loaded from firebase \(dateLoadedFromFirebaseDataSet)")
            
            if(dateLoadedFromFirebaseDataSet == fullyCorrectedDate){
                //match for date found
                print("hello!")
                itemsCheckedOutLbl.center = CGPoint(x: midX, y: midY + 300)
                itemsCheckedOutLbl.textAlignment = .center
                itemsCheckedOutLbl.text = "Item's Checked Out: \(dataLoadedIn[x]["itemsCheckedOut"]!)"
                addSubview(itemsCheckedOutLbl)
//                //
                studentsVisitedLbl.center = CGPoint(x: midX, y: midY + 500)
                studentsVisitedLbl.textAlignment = .center
                studentsVisitedLbl.text = "Student's Visited: \(dataLoadedIn[x]["studentsVisited"]!)"
                addSubview(studentsVisitedLbl)
                
                dataWasFound = true;
            }
        }
        print(dataWasFound)
        if(!dataWasFound){
            itemsCheckedOutLbl.center = CGPoint(x: midX, y: midY + 300)
            itemsCheckedOutLbl.textAlignment = .center
            itemsCheckedOutLbl.text = "NO DATA FOR THIS DAY!"
            addSubview(itemsCheckedOutLbl)
        }
    }
    
    //all firebaes handling below
    var dataLoadedIn : [[String: Any]] =  []
    func loadInFirebaseTextDataAboutStatistics(){
        //get the dates and items/students visited with those dates
        self.ref.child("Conant High School").child("Statistics").child("Total Visits").observeSingleEvent(of: .value, with: { (snapshot) in

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
                c += 1
            }
            self.dataLoadedIn = tempData;
            
            
        }) { (error) in
            RequestError().showError()
            print(error.localizedDescription)
        }
        
    }

    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=UIColor.clear
        let lbl = cell?.subviews[1] as! UILabel
        lbl.textColor = Style.activeCellLblColor
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/7 - 8
        let height: CGFloat = 40
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        //return day == 7 ? 1 : day
        return day
    }
    
    func didChangeMonth(monthIndex: Int, year: Int) {
        currentMonthIndex=monthIndex+1
        currentYear = year
        
        //for leap year, make february month of 29 days
        if monthIndex == 1 {
            if currentYear % 4 == 0 {
                numOfDaysInMonth[monthIndex] = 29
            } else {
                numOfDaysInMonth[monthIndex] = 28
            }
        }
        //end
        
        firstWeekDayOfMonth=getFirstWeekDay()
        
        myCollectionView.reloadData()
        
        monthView.btnLeft.isEnabled = true;
//        !(currentMonthIndex == presentMonthIndex && currentYear == presentYear)
    }
    
    func setupViews() {
        addSubview(monthView)
        monthView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        monthView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        monthView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        monthView.heightAnchor.constraint(equalToConstant: 35).isActive=true
        monthView.delegate=self
        
        addSubview(weekdaysView)
        weekdaysView.topAnchor.constraint(equalTo: monthView.bottomAnchor).isActive=true
        weekdaysView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        weekdaysView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        weekdaysView.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
        addSubview(myCollectionView)
        myCollectionView.topAnchor.constraint(equalTo: weekdaysView.bottomAnchor, constant: 0).isActive=true
        myCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive=true
        myCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive=true
        myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    let monthView: MonthView = {
        let v=MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let weekdaysView: WeekdaysView = {
        let v=WeekdaysView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let myCollectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.translatesAutoresizingMaskIntoConstraints=false
        myCollectionView.backgroundColor=UIColor.clear
        myCollectionView.allowsMultipleSelection=false
        return myCollectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class dateCVCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
        layer.cornerRadius=5
        layer.masksToBounds=true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(lbl)
        lbl.topAnchor.constraint(equalTo: topAnchor).isActive=true
        lbl.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        lbl.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        lbl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    let lbl: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font=UIFont.systemFont(ofSize: 16)
        label.textColor=Colors.darkGray
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
}

//get date from string
extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
}












