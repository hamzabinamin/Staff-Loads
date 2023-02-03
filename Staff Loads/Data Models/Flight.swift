//
//  Flight.swift
//  Staff Loads
//
//  Created by Hamza Amin on 19/12/2022.
//

import Foundation
import UIKit

struct Departure {
    var date: String
    var time: String
    var country: String
}

struct Arrival {
    var date: String
    var time: String
    var country: String
}

struct FlightData {
    var flightNumber: String
    var airplaneModel: String
    var meal: String
    var route: String
}

class Flight: Identifiable {
    var departure: Departure
    var arrival: Arrival
    var airline: String
    var flightData: FlightData
    var seats: String

    init() {
        departure = Departure(date: "", time: "", country: "")
        arrival = Arrival(date: "", time: "", country: "")
        airline = ""
        flightData = FlightData(flightNumber: "", airplaneModel: "", meal: "", route: "")
        seats = ""
    }
    
    func getNumberOfSeatsPerClass(flightClass: String) -> String {
        // F first
        // J busimess
        //  W premium economy
        //  Y economy
        var string = "0"
        if seats.contains(flightClass) {
            if let index = seats.range(of: flightClass)?.upperBound {
                let endIndex = seats.index(index, offsetBy: 1)
                let substring = seats[index...endIndex]
                string = String(substring)
            }
        }
        return string
    }
    
}
