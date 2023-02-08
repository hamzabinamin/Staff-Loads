//
//  ListDesign.swift
//  Staff Loads
//
//  Created by Hamza Amin on 24/01/2023.
//

import SwiftUI

struct ListDesign: View {
    @State var flight: Flight
  
    var body: some View {
      //  Color.init(UIColor(red: 65, green: 146, blue: 211))
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(Color.init(UIColor(rgb: 0x00B0F0)))
                .frame(height: 370)
            VStack() {
                HStack() {
                    VStack(alignment: .leading) {
                        Text(flight.departure.date)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                            .font(.system(size: 14.0)).bold()
                        Text(flight.airline)
                            .foregroundColor(.white)
                            .font(.system(size: 14.0))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack() {
                        Text(flight.flightData.flightNumber)
                            .frame(maxWidth: 500, alignment: .center)
                            .foregroundColor(.white)
                            .font(.system(size: 12.0)).bold()
                            .padding(5)
                            .background(.red)
                            .cornerRadius(20)
                        Text(flight.flightData.airplaneModel)
                            .frame(maxWidth: 500, alignment: .center)
                            .foregroundColor(.white)
                            .font(.system(size: 12.0)).bold()
                            .padding(5)
                            .background(.red)
                            .cornerRadius(20)
                    }
                }
                .padding()
                
                HStack() {
                    Text(flight.departure.time)
                        .frame(maxWidth: 500, alignment: .leading)
                        .foregroundColor(.white)
                        .font(.system(size: 24.0)).bold()

                    
                    VStack {
                        Text(flight.departure.country)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .font(.system(size: 14.0)).bold()
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Image("Route White")
                          .resizable()
                          .frame(width: 60, height: 50, alignment: .bottom)
                       
                        Text(flight.arrival.country)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .font(.system(size: 14.0)).bold()
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                       
                    }
                    Text(flight.arrival.time)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.white)
                        .font(.system(size: 24.0)).bold()
                }
                .padding(15)
                
                let f = flight.getNumberOfSeatsPerClass(flightClass: "F")
                let j = flight.getNumberOfSeatsPerClass(flightClass: "J")
                let w = flight.getNumberOfSeatsPerClass(flightClass: "W")
                let y = flight.getNumberOfSeatsPerClass(flightClass: "Y")
                
                HStack(spacing: 10.0) {
                    Text("F: " + "\(f["seats"] ?? "0")")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.init(uiColor: UIColor(rgb: f["color"] as! Int)))
                        .font(.system(size: 15.0)).bold()
                
                    Text("J: " + "\(j["seats"] ?? "0")")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.init(uiColor: UIColor(rgb: j["color"] as! Int)))
                        .font(.system(size: 15.0)).bold()
                    
                    Text("W: " + "\(w["seats"] ?? "0")")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.init(uiColor: UIColor(rgb: w["color"] as! Int)))
                        .font(.system(size: 15.0)).bold()
                    
                    Text("Y: " + "\(y["seats"] ?? "0")")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.init(uiColor: UIColor(rgb: y["color"] as! Int)))
                        .font(.system(size: 15.0)).bold()
                }
                .padding(15)
                
                HStack(spacing: 40.0) {
                    Image("Seat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                   
                    Image("Seat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                   
                    Image("Seat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                    
                    Image("Seat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 15)
                .padding(.trailing, 15)
            }
        }
        .padding()
    }
}

struct ListDesign_Previews: PreviewProvider {
    static var previews: some View {
        ListDesign(flight: Flight())
    }
}
