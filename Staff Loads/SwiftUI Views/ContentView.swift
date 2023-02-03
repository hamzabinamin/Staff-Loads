//
//  ContentView.swift
//  Staff Loads
//
//  Created by Hamza Amin on 30/11/2022.
//

import Foundation
import UIKit
import SwiftUI
import WebKit
import SwiftSoup

struct ContentView: View {
    let url = URL(string: "https://www.tictas.com/schedule/checkAirAvailability.do")!
    @StateObject var properties = Properties()
    @StateObject var shouldNavigate = ShouldNavigate()
    
    init() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().backgroundColor = UIColor(rgb: 0x00B0F0)
    }
    
    var title = "Staff Loads"
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        HeaderSection()
                        MiddleFirstSection(properties: properties)
                        MiddleSecondSection(properties: properties)
                    }
                    BottomSection(properties: properties, shouldNavigate: shouldNavigate)
                }
            
                if shouldNavigate.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(3)
                }
            }
            .accentColor(Color.init(uiColor: UIColor(rgb: 0x00B0F0)))
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .navigationBarHidden(false)
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .navigate(to: FlightsView(properties: properties, shouldNavigate: shouldNavigate), when: $shouldNavigate.shouldGo)
        .alert(isPresented: $shouldNavigate.showAlert) {
            Alert(title: Text("Error"), message: Text(shouldNavigate.error), dismissButton: .default(Text("OK")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HeaderSection: View {
    var body: some View {
        Section {
            Text("Flight Availability Checker")
                .font(Font.headline.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}

struct MiddleFirstSection: View {
    @ObservedObject var properties: Properties
  
    var body: some View {
        VStack {
            HStack {
                Section {
                    Text("Departure").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Arrival").frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            HStack {
                Section {
                    TextField("HKG", text: $properties.departure)
                        .padding(.all)
                        .multilineTextAlignment(.leading)
                    TextField("CPT", text: $properties.arrival)
                        .padding(.all)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            HStack {
                Section {
                    Text("Select Airport").frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "repeat.1.circle.hi")
                    Text("Select Airport").frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

struct MiddleSecondSection: View {
    @ObservedObject var properties: Properties
    
    var body: some View {
        VStack {
            HStack {
                Section {
                    Image(systemName: "calendar")
                    Text("Departure Date")
                }
            }
            .padding()
            
            HStack {
                Section {
                    DatePicker("", selection: $properties.date, displayedComponents: [.date])
                    .labelsHidden()
                    .padding(.all)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct BottomSection: View {
    @StateObject var model = WebViewModel()
    @ObservedObject var properties: Properties
    @ObservedObject var shouldNavigate: ShouldNavigate
    let formatter = DateFormatter()
    
    var body: some View {
        Button(action: {
            formatter.dateFormat = "ddMMMyy"
            print("tapped!")
            print(self.properties.departure)
            print(self.properties.arrival)
            print(formatter.string(from: self.properties.date))
            
            if(self.properties.departure.count > 0 && self.properties.arrival.count > 0) {
                shouldNavigate.loading = true
                model.loadUrl()
                model.setProperties(properties: properties)
                model.setShouldNavigate(shouldNavigate: shouldNavigate)
            }
            else {
                shouldNavigate.loading = false
                shouldNavigate.error = "Please provide a departure and arrival airport"
                shouldNavigate.showAlert = true
            }
        }, label: {
            Text("Search Flight")
            .foregroundColor(.white)
            .frame(width: 200, height: 40)
            .background(Color.init(UIColor(rgb: 0x00B0F0)))
            .cornerRadius(15)
            .padding()
        }).frame(maxHeight: 60, alignment: .bottom)
    }
}

class Properties: ObservableObject {
    @Published var departure = ""
    @Published var arrival = ""
    @Published var date = Date()
    @Published var flightArray = [Flight]()
}

class ShouldNavigate: ObservableObject {
    @Published var shouldGo = false
    @Published var loading = false
    @Published var showAlert = false
    @Published var error = ""
}

class WebViewModel: ObservableObject {
    let webView: WKWebView
    let url: URL
    let page = 0
    private let navigationDelegate: WebViewNavigationDelegate
    @ObservedObject var properties: Properties
    @ObservedObject var shouldNavigate: ShouldNavigate
     
    init() {
        webView = WKWebView(frame: .zero)
        navigationDelegate = WebViewNavigationDelegate()
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

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
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
                getFlightsData(html: html, properties: self.properties, shouldNavigate: self.shouldNavigate)
            }
        }
    }
}

func getFlightsData(html: String, properties: Properties, shouldNavigate: ShouldNavigate) {
    do {
        let doc: Document = try SwiftSoup.parse(html)
        if try doc.select("tbody tr td").array().count > 0 && 1 < doc.select("tbody tr td").array().count {
            print("Inside if")
            shouldNavigate.loading = false
           // let td: Element = try doc.select("tbody tr td").array()[1]
           // let text: String = try td.text()
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
            shouldNavigate.shouldGo = true
        }
        else {
            print("Inside else")
            shouldNavigate.loading = false
            shouldNavigate.error = "No flights are available for this date"
            shouldNavigate.showAlert = true
        }
    }
    catch let error {
        print(error.localizedDescription)
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
