//
//  FlightsView.swift
//  Staff Loads
//
//  Created by Hamza Amin on 24/01/2023.
//

import SwiftUI
import WebKit
import SwiftSoup

struct FlightsView: View {
    @ObservedObject var propertiesStoreObject = Properties()
    @StateObject var shouldNavigate = ShouldNavigate()
   
    init(properties: Properties, shouldNavigate: ShouldNavigate) {
        UITableView.appearance().showsVerticalScrollIndicator = false
        propertiesStoreObject = properties
        print("Arrival 2", propertiesStoreObject.arrival)
        print("Departure 2", propertiesStoreObject.departure)
    }
    
    init() {
        UINavigationBar.appearance().tintColor = .white
    }
    
    var title = "Staff Loads"
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    HeaderSectionFlights()
                    MiddleSectionFlights(properties: propertiesStoreObject)
                }
                BottomSectionFlights(properties: propertiesStoreObject, shouldNavigate: shouldNavigate)
            }.preferredColorScheme(.light)
            .navigationTitle(title)
        }
        .accentColor(.white)
    }
}

struct FlightsView_Previews: PreviewProvider {
    
    static var previews: some View {
        FlightsView()
    }
}

struct HeaderSectionFlights: View {
    
    var body: some View {
        Section {
            Text("Availability")
                .font(Font.headline.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct MiddleSectionFlights: View {
    @ObservedObject var properties: Properties
    var body: some View {
        VStack {
            ForEach(properties.flightArray) { item in
                ListDesign(flight: item)
            }
        }
       // .background(Color.red.ignoresSafeArea())
    }
}

struct BottomSectionFlights: View {
    @StateObject var model = WebViewModel2()
    @ObservedObject var properties: Properties
    @ObservedObject var shouldNavigate: ShouldNavigate
    
    var body: some View {
        HStack {
            Button(action: {
                print("tapped!")
                shouldNavigate.loading = true
                properties.flightArray = []
                model.loadUrl()
                model.setProperties(properties: properties)
                model.setShouldNavigate(shouldNavigate: shouldNavigate)
            }, label: {
                Text("Refresh")
                .foregroundColor(.white)
                .frame(width: 200, height: 40)
                .background(Color.init(UIColor(rgb: 0x00B0F0)))
                .cornerRadius(15)
                .padding()
            }).frame(maxHeight: 60, alignment: .bottom)
            
            if shouldNavigate.loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1)
                    .padding(.top, -10)
            }
        }
    }
}

class WebViewModel2: ObservableObject {
    let webView: WKWebView
    let url: URL
    let page = 0
    private let navigationDelegate: WebViewNavigationDelegate2
    @ObservedObject var properties: Properties
    @ObservedObject var shouldNavigate: ShouldNavigate
     
    init() {
        webView = WKWebView(frame: .zero)
        navigationDelegate = WebViewNavigationDelegate2()
        webView.navigationDelegate = navigationDelegate
        url = URL(string: "https://www.tictas.com/schedule/checkAirAvailability.do")!
        properties = Properties()
        shouldNavigate = ShouldNavigate()
    }
    
    func loadUrl() {
        webView.load(URLRequest(url: url))
    }
     
    func setProperties(properties: Properties) {
        self.properties = properties
        navigationDelegate.setProperties(properties: properties)
    }
     
    func setShouldNavigate(shouldNavigate: ShouldNavigate) {
        self.shouldNavigate = shouldNavigate
        navigationDelegate.setShouldNavigate(shouldNavigate: shouldNavigate)
    }
}

class WebViewNavigationDelegate2: NSObject, WKNavigationDelegate {
    @ObservedObject var properties: Properties
    @ObservedObject var shouldNavigate: ShouldNavigate
    var page = 0
    
    override init() {
        properties = Properties()
        shouldNavigate = ShouldNavigate()
    }
    
    func setProperties(properties: Properties) {
        self.properties = properties
    }
    
    func setShouldNavigate(shouldNavigate: ShouldNavigate) {
        self.shouldNavigate = shouldNavigate
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish got called")
        
        if page == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                print("now doing js")
                let formatter = DateFormatter()
                formatter.dateFormat = "ddMMMyy"
                print(self.properties.departure)
                print(self.properties.arrival)
                print(formatter.string(from: self.properties.date))
                let jsString1 = "document.querySelector('input[value=HKG]').value = '\(self.properties.departure)';"
                let jsString2 = "document.querySelector('input[value=SIN]').value = '\(self.properties.arrival)';"
                let jsString3 = "document.querySelector('#datepicker').value = '\(formatter.string(from: self.properties.date))';"
                let jsString4 = "document.querySelector('.nobdr').click();"
                let jsString = jsString1 + jsString2 + jsString3 + jsString4
                
                print(jsString1)
                
                webView.evaluateJavaScript(jsString) { (value, error) in

                    if let err = error {
                        print("err: ", err)
                    }
                    else {
                        print("value: ", value)
                        self.page = 1
                    }
                }
            }
        }
        else {
            webView.evaluateJavaScript("document.documentElement.outerHTML") { (html, error) in
                self.page = 0
                guard let html = html as? String else {
                    print(error.debugDescription)
                    return
                }
               // print(html)
                refreshFlightsData(html: html, properties: self.properties, shouldNavigate: self.shouldNavigate)
            }
        }
    }
}

func refreshFlightsData(html: String, properties: Properties, shouldNavigate: ShouldNavigate) {
    do {
        let doc: Document = try SwiftSoup.parse(html)
        if try doc.select("tbody tr td").array().count > 0 && 1 < doc.select("tbody tr td").array().count {
            print("Inside if")
            shouldNavigate.loading = false
            let document = try! SwiftSoup.parse(html)
            var i = 0
            var rowContent = [String]()
            
            for row in try! document.select("table tr") {
                print("row.select(td).count: ", try! row.select("td").count)
                if try! row.select("td").count > 1 {
                    for col in try! row.select("td") {
                        let colContent = try! col.text()
                        print(i)
                        print(colContent)
                        if i > 4 {
                            rowContent.append(colContent)
                        }
                        i = i + 1
                    }
                    
                    if rowContent.count > 0 {
                        let flight = Flight()
                        let departureData = rowContent[0].split(separator: " ")
                        let arrivalData = rowContent[1].split(separator: " ")
                        flight.departure.date = "\(departureData[0])"
                        flight.departure.time = "\(departureData[1])"
                        flight.departure.country = (departureData.count > 3) ? "\(departureData[2])" + " " + "\(departureData[3])" : "\(departureData[2])"
                        flight.arrival.date = "\(arrivalData[0])"
                        flight.arrival.time = "\(arrivalData[1])"
                        flight.arrival.country = (arrivalData.count > 3) ? "\(arrivalData[2])" + " " + "\(arrivalData[3])" : "\(arrivalData[2])"

                        flight.airline = rowContent[2]
                        
                        if (4 >= 0 && rowContent.count > 4) {
                            let flightData = rowContent[4]
                            let flightNumberComplete = flightData.components(separatedBy: " Model")
                            let airplaneModelComplete = flightData.components(separatedBy: " Meal")
                            
                            if let index = flightNumberComplete[0].range(of: "Flight: ")?.upperBound {
                                let substring = flightNumberComplete[0][index...]
                                let string = String(substring)
                                flight.flightData.flightNumber = string
                            }
                            
                            if let index = airplaneModelComplete[0].range(of: "Model : ")?.upperBound {
                                let substring = airplaneModelComplete[0][index...]
                                let string = String(substring)
                                flight.flightData.airplaneModel = string
                            }
                            flight.seats = rowContent[5]
                        }
                    
                        properties.flightArray.append(flight)
                        rowContent = [String]()
                        print(flight.departure.date)
                        print(flight.departure.time)
                        print(flight.departure.country)
                        print(flight.arrival.date)
                        print(flight.arrival.time)
                        print(flight.arrival.country)
                        print(flight.airline)
                        print(flight.flightData.flightNumber)
                        print(flight.flightData.airplaneModel)
                        print(flight.seats)
                        print("F: ", flight.getNumberOfSeatsPerClass(flightClass: "F"))
                        print("J: ", flight.getNumberOfSeatsPerClass(flightClass: "J"))
                        print("W: ", flight.getNumberOfSeatsPerClass(flightClass: "W"))
                        print("Y: ", flight.getNumberOfSeatsPerClass(flightClass: "Y"))
                    }
                }
            }
        }
        else {
            print("Inside else")
            shouldNavigate.loading = false
            shouldNavigate.showAlert = true
        }
    }
    catch let error {
        print(error.localizedDescription)
    }
}

