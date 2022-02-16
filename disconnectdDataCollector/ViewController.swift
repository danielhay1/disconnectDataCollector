//
//  ViewController.swift
//  disconnectdDataCollector
//
//  Created by user214504 on 2/13/22.
//

import UIKit
import Charts

let DisconnectNotficationKey = "com.example.disconnectedDataCollector.dc_detector"
class ViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barChart: BarChartView!
    private var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        self.createObserver()
        DispatchQueue.global(qos: .userInitiated).async {
            self.events = DB_Manager.shared.loadAllEvents()     // Load events from db
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setupChart()
            }
        }
    }

    @IBAction func BtnResetDB(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            DB_Manager.shared.clearEventsTable()
            self.events = DB_Manager.shared.loadAllEvents()     // Load events from db
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setupChart()
            }
        }
    }
    
    func addEvent(event: Event) {
        DispatchQueue.global(qos: .userInitiated).async {
            let index = self.addEventToDB(event: event)
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                let indexPath = IndexPath(item: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                self.tableView.endUpdates()
                self.setupChart()
            }
        }
    }
    
    func addEventToDB(event: Event) -> Int {
        /**/
        var index: Int = 0
        for value in self.events {
            if(value == event) {
                self.events[index].count+=1
                print("event updated, index: \(index)")
                DB_Manager.shared.insertEvent(event: value)
                index+=1
            }
        }
        return index
    }
        
    // MARK: Visualizing Data
    private func transformToBarChartDataEntry(index: Int ,event: Event) -> BarChartDataEntry {
        return BarChartDataEntry(x: Double(index), y: Double(event.count))
    }
    
    private func prepareData() -> [String]{
        var rawData: [String] = []
        for event in events {
            rawData.append("\(event.time), \(event.count)")
        }
        return rawData
    }
    
    private func setupData() {
        let dataEntries = events.enumerated().map{ transformToBarChartDataEntry(index: $0, event: $1) }
        let set1 = BarChartDataSet(entries: dataEntries)
        set1.label = "Internet disconnect num of occurrences"
        set1.highlightColor = .systemBlue
        set1.highlightAlpha = 1
        let data = BarChartData(dataSet: set1)
        data.setDrawValues(true)
        barChart.data = data

        // Remove right axis
        barChart.rightAxis.enabled = false
        barChart.leftAxis.axisMinimum = 0
        
        // Setup X axis
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.setLabelCount(events.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: events.map { String($0.time.prefix(2)) })
        xAxis.axisMaximum = Double(events.count)
            
    }
    
    func setupChart() {
        setupData()
        barChart.delegate = self
        // Hightlight
        barChart.highlightPerTapEnabled = true
        barChart.highlightFullBarEnabled = true
        barChart.highlightPerDragEnabled = false
        
        // Bar, Grid Line, Background
        barChart.highlightPerTapEnabled = true
        barChart.highlightFullBarEnabled = true
        barChart.highlightPerDragEnabled = false
        barChart.setExtraOffsets(left: 10, top: 0, right: 20, bottom: 10)
        // Animation
        barChart.animate(yAxisDuration: 1.5 , easingOption: .easeOutBounce)
        
    }
    // MARK: manage observer:
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEvent(notfication:)), name: Notification.Name(DisconnectNotficationKey), object: nil)
        
    }
    
    @objc func updateEvent(notfication: NSNotification) {
        addEvent(event: Event())
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.time.text = String(events[indexPath.row].time)
        cell.count.text = String(events[indexPath.row].count)
        return cell
    }

}
