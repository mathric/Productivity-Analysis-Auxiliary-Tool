//
//  ViewController.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/4.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Cocoa
import Foundation
import CoreData
import Charts

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var activityBarChartView: BarChartView!
    @IBOutlet weak var productivityLineChartView: LineChartView!
    @IBOutlet weak var productivitySegmentControl: NSSegmentedControl!
    @IBOutlet weak var periodSelectingSegmentControl: NSSegmentedControl!
    @IBOutlet weak var activityHistorySegmentControl: NSSegmentedControl!
    @IBOutlet weak var applicationUsageTableView: NSTableView!
    @IBOutlet weak var applicationTitleLabel: NSTextField!
    var coreDataList:[CoreDataActivity] = []
    var activityList:[ActivityModel] = []
    var appDelegate = (NSApplication.shared.delegate as? AppDelegate)!
    var myContext = ((NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    let timer = CustomTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applicationUsageTableView.delegate = self
        applicationUsageTableView.dataSource = self
        let defaultPredicate = ActivityModelFetch.lastWeek()
        updateViewTable(predicate: defaultPredicate, arrangeList:ActivityTableViewFilter.sortByTimeUsage)
        periodSelectingSegmentControl.action = #selector(periodSelectingChange)
        activityHistorySegmentControl.action = #selector(historySelectingChange)
        productivitySegmentControl.action = #selector(productivitySegmentSelectingChange)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRowByIndex), name: NSNotification.Name(rawValue: "UpdateRowData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.appendToActivityList), name: NSNotification.Name(rawValue: "AddNewElementToActivityList"), object: nil)
        initActivityBarChart()
        initProductivityLineChart()
        timer.setTimer(activityList: activityList, detectCore: appDelegate.detectCore)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        //initial set up
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    
    func fetchCoreData<T:NSPredicate>(predicate:T, coreDataList:inout [CoreDataActivity]) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        
        coreDataList.removeAll()
        fetch.predicate = predicate
        do {
            let result = try myContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                coreDataList.append(data as! CoreDataActivity)
                //print(data.value(forKey: "applicationName") as! String)
            }
        } catch {
            print("Failed")
        }
    }
    
    

    // MARK: - TableView
    //allow both NSCompoundPredicate or NSPredicate
    func updateViewTable<T:NSPredicate>(predicate:T, arrangeList:(([CoreDataActivity])->([ActivityModel]))?) {
        fetchCoreData(predicate: predicate, coreDataList: &coreDataList)
        if let sortFunc = arrangeList {
            activityList = sortFunc(coreDataList)
        }
        self.applicationUsageTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let columnID = tableColumn?.identifier.rawValue {
            switch columnID {
            case "applicationNameColumn":
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "applicationNameCell"), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = self.activityList[row].applicationName
                return cell
            case "usageColumn":
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "usageCell"), owner: self) as? NSTableCellView
                cell?.textField?.stringValue = CustomDate.dcf.string(from: self.activityList[row].usageTime)!
                return cell
            default:
                break
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        applicationTitleLabel.stringValue = getChartApplicationName() ?? "Unknown"
        switch activityHistorySegmentControl.selectedSegment {
        case 0:
            updateHistoryChartView(dataFetchMethod: ChartData.timeUsageCount)
            break
        case 1:
            updateHistoryChartView(dataFetchMethod: ChartData.mouseClickCount)
            break
        case 2:
            updateHistoryChartView(dataFetchMethod: ChartData.keyPressCount)
            break
        default:
            return
        }
    }
    
    @objc func updateRowByIndex(notification: Notification) {
        if let rowIndexes = notification.userInfo?["index"] as? IndexSet {
            //col is 2, not good method to use [0,1]
            self.applicationUsageTableView.reloadData(forRowIndexes: rowIndexes, columnIndexes: [0, 1])
        }
    }
    
    // MARK: - periodSelectingSegmentControl
    @objc func periodSelectingChange(segment: NSSegmentedControl) {
        var predicate:NSPredicate
        switch segment.selectedSegment {
        case 0:
            predicate = ActivityModelFetch.today()
            break
        case 1:
            predicate = ActivityModelFetch.lastWeek()
            break
        case 2:
            predicate = ActivityModelFetch.lastMonth()
            break
        default:
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateActivityData"), object: nil)
        updateViewTable(predicate: predicate, arrangeList:ActivityTableViewFilter.sortByTimeUsage)
        activityBarChartView.clear()
        timer.stopTimer()
        timer.setTimer(activityList: activityList, detectCore: appDelegate.detectCore)
    }
    
    // MARK: - activitylist
    
    @objc func appendToActivityList(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let newElement = (userInfo["newElement"] as? ActivityModel) {
                activityList.append(newElement)
                self.applicationUsageTableView.insertRows(at: [activityList.count-1])
                timer.stopTimer()
                timer.setTimer(activityList: activityList, detectCore: appDelegate.detectCore)
            }
        }
    }
    
    
    //MARK: - activityBarChartView
    
    func initActivityBarChart() {
        activityBarChartView.noDataText = "no data for the chart."
        activityBarChartView.drawBordersEnabled = true
        activityBarChartView.borderLineWidth = 0.5
        activityBarChartView.borderColor = .black
        activityBarChartView.legend.enabled = false;
        activityBarChartView.scaleYEnabled = false
        activityBarChartView.doubleTapToZoomEnabled = false
        activityBarChartView.dragEnabled = false
        activityBarChartView.xAxis.axisLineWidth = 1.0
        activityBarChartView.xAxis.labelPosition = .bottom
        activityBarChartView.xAxis.labelCount = 24
        activityBarChartView.xAxis.drawGridLinesEnabled = false
        activityBarChartView.leftAxis.forceLabelsEnabled = false
                
        //default setting is mouse click
        updateHistoryChartView(dataFetchMethod: ChartData.mouseClickCount)
    }
    
    func getChartApplicationName() -> String? {
        if applicationUsageTableView.selectedRow < 0 {
            return nil
        }
        else {
            return activityList[applicationUsageTableView.selectedRow].applicationName
        }
    }
    
    func updateHistoryChartView(dataFetchMethod: ((_ coredata:[CoreDataActivity], _ applicationName:String)->[Double])) {
        var dataEntries: [BarChartDataEntry] = []
        if let appName = getChartApplicationName() {
            let clickData = dataFetchMethod(coreDataList, appName)
            
            for i in 0..<clickData.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: clickData[i])
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.highlightEnabled = false
            let chartData = BarChartData(dataSet: chartDataSet)
            activityBarChartView.data = chartData
        }
    }
    
    //MARK: - productivityLineChartView
    func initProductivityLineChart() {
        productivityLineChartView.noDataText = "no data for the chart."
        productivityLineChartView.drawBordersEnabled = true
        productivityLineChartView.borderLineWidth = 0.5
        productivityLineChartView.borderColor = .black
        productivityLineChartView.legend.enabled = false;
        productivityLineChartView.scaleYEnabled = false
        productivityLineChartView.doubleTapToZoomEnabled = false
        productivityLineChartView.dragEnabled = false
        productivityLineChartView.xAxis.axisLineWidth = 1.0
        productivityLineChartView.xAxis.labelCount = 24
        productivityLineChartView.xAxis.labelPosition = .bottom
        productivityLineChartView.xAxis.drawGridLinesEnabled = false
        productivityLineChartView.leftAxis.forceLabelsEnabled = false

        updateProductivityChartView(predicate: ActivityModelFetch.lastWeekWithoutToday())
    }
    
    //predicate to choose last week or last month
    //use two line to hide the data after current hour
    func updateProductivityChartView(predicate:NSPredicate) {
        var todayData:[CoreDataActivity] = []
        var compData:[CoreDataActivity] = []
        var invisibleDataEntries: [ChartDataEntry] = []
        var visibleDataEntries: [ChartDataEntry] = []
        var productivityData:[Double] = []
        fetchCoreData(predicate: predicate, coreDataList: &compData)
        fetchCoreData(predicate: ActivityModelFetch.today(), coreDataList: &todayData)
        productivityData = ChartData.getProductivityData(todayData: todayData, compareData: compData)
        
        for i in 0..<productivityData.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: productivityData[i])
            invisibleDataEntries.append(dataEntry)
        }
        
        for i in 0 ..< productivityData.count {
            if productivityData[i] == -1 {
                break;
            }
            let dataEntry = ChartDataEntry(x: Double(i), y:productivityData[i])
            visibleDataEntries.append(dataEntry)
        }
        
        let invisibleChartDataSet = LineChartDataSet(entries: invisibleDataEntries)
        invisibleChartDataSet.colors = [NSUIColor.clear]
        invisibleChartDataSet.drawCirclesEnabled = false
        invisibleChartDataSet.drawValuesEnabled  = false
        
        let visibleChartDataSet = LineChartDataSet(entries: visibleDataEntries)
        visibleChartDataSet.drawValuesEnabled = false
        visibleChartDataSet.highlightEnabled = false
        visibleChartDataSet.circleRadius = 5
        
        let chartData = LineChartData(dataSets: [invisibleChartDataSet, visibleChartDataSet])
        productivityLineChartView.data = chartData
    }
    
    
    //MARK: - activityHistorySegmentControl
    
    @objc func historySelectingChange(segment: NSSegmentedControl) {
        switch segment.selectedSegment {
        case 0:
            updateHistoryChartView(dataFetchMethod: ChartData.timeUsageCount)
            break
        case 1:
            updateHistoryChartView(dataFetchMethod: ChartData.mouseClickCount)
            break
        case 2:
            updateHistoryChartView(dataFetchMethod: ChartData.keyPressCount)
            break
        default:
            return
        }
    }
    
    
    // MARK: - ProductivitySegmentControl
    @objc func productivitySegmentSelectingChange(segment: NSSegmentedControl) {
        var predicate:NSPredicate
        switch segment.selectedSegment {
        case 0:
            predicate = ActivityModelFetch.lastWeekWithoutToday()
            updateProductivityChartView(predicate: predicate)
            break
        case 1:
            predicate = ActivityModelFetch.lastMonthWithoutToday()
            updateProductivityChartView(predicate: predicate)
            break
        default:
            return
        }
        
    }
}

