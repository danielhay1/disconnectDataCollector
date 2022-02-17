//
//  Database.swift
//  disconnectdDataCollector
//
//  Created by user214504 on 2/13/22.
//

import Foundation
import SQLite

class DB_Manager {
    // sqlite instance
    private(set) static var shared = DB_Manager()
    private var db: Connection!
    
    // table instance
    private var eventsTable: Table!
    
    // columns instances of table
    private var time: Expression<String>!
    private var count: Expression<Int64>!
    
    private init () {
        // exception handling
        do {
            // path of document directory
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            // creating database connection
            db = try Connection("\(path)/my_events.sqlite3")
            // creating table object
            eventsTable = Table("events")
            
            // create instances of each column
            time = Expression<String>("time")
            count = Expression<Int64>("count")

            print("Is table created already: \(UserDefaults.standard.bool(forKey: "is_db_created"))")
            // check if the events's table is already created
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                // if not, then create the table
                try db.run(eventsTable.create { (t) in
                    t.column(time, primaryKey: true)
                    t.column(count)
                })
                print("Creating db...")
                // set the value to true, so it will not attempt to create the table again
                UserDefaults.standard.set(true, forKey: "is_db_created")
                initAllEvents()
            }
            
        } catch {
            // show error message if any
            print(error.localizedDescription)
        }
        print("DB created successfully")
    }
    
    private func initAllEvents() {
        for i in 0...23 {
            var tempTime: String
            if(i<10){
                tempTime = "0\(i)"
            } else {
                tempTime = "\(i)"
            }
            let event = Event()
            event.setCustomtTime(time: tempTime)
            insertEvent(event: event,isDBInitInsertion: true)
        }
    }
    
    public func insertEvent(event: Event,isDBInitInsertion: Bool = false) {
        do{
            try db.transaction {
                // update row in case key exists
                let filteredTable = eventsTable.filter(time == event.time)
                if try db.run(filteredTable.update(count += 1)) > 0 {
                    print("Row updated: time= \(event.time)")
                } else { // update returned 0 because there was no match
                    // insert the event
                    if(isDBInitInsertion) {
                        try db.run(eventsTable.insert(time <- event.time, count <- 0))
                    } else {
                        let rowid = try db.run(eventsTable.insert(time <- event.time, count <- 1))
                        print("inserted id: \(rowid)")
                    }
                }
            }
        } catch {
            print("insertEvent failded: \(error)")
        }
    }
    
    public func clearEventsTable() {
        let drop = eventsTable.drop(ifExists: true)
        do {
            try db.run(drop)
            UserDefaults.standard.set(false, forKey: "is_db_created")
            DB_Manager.shared = DB_Manager()
        } catch {
            print("deleteEventTable failded: \(error)")
        }
    }
    
    public func loadAllEvents() -> [Event]{
        var eventList: [Event] = []
        do {
            for events in try db.prepare(eventsTable) {
                do {
                    try eventList.append(Event(time: events.get(time),count: Int(events.get(count))))
                } catch {
                    print("loadAllEvents: Load event from db failed: \(error)")
                }
            }
        } catch {
            print("loadAllEvents: failed to connect db: \(error)")
        }
        return eventList
    }
    
}
