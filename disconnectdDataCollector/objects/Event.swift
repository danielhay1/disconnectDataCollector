//
//  Event.swift
//  disconnectdDataCollector
//
//  Created by user214504 on 2/13/22.
//

import Foundation
class Event: Identifiable, Equatable {
    
    private(set) var time: String = "NA"
    var count: Int = 0
    init(time: String){
        self.time = time
    }
    
    init(time: String, count: Int) {
        self.time = time
        self.count = count
    }
    
    init() {
        setCurrentTime()
    }
    
    private func setCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh"
        let nextHourDate = Calendar.current.date(
          byAdding: .hour,
          value: +1,
          to: Date())
        
        self.time = "\(formatter.string(from: Date())):00 - \(Int(formatter.string(from: nextHourDate!))!):00"
    }
    
    func setCustomtTime(time: String) {
        /*
         function get "hh" string date format an create set event time.
         input example: "01","09","12","24"..
         */
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        guard let date = formatter.date(from: time) else {
            print("setCustomtTime string date casting failed, \(time)")
            return
        }
        let nextHourDate = Calendar.current.date(
          byAdding: .hour,
          value: +1,
          to: date)
        
        self.time = "\(formatter.string(from: date)):00 - \(Int(formatter.string(from: nextHourDate!))!):00"
    }
    
    
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.time == rhs.time
    }
    
    public var description: String { return "Event: time = \(self.time), count = \(self.count)" }
}
