//
//  Neuland_Food_Widget.swift
//  Neuland Food Widget
//
//  Created by Robert Eggl on 08.10.22.
//

import WidgetKit
import SwiftUI


struct Provider: IntentTimelineProvider {
    let provider = FoodWidgetProvider()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), mensaData: FoodElement.placeholder, configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        provider.getMensaData(location: configuration.location) { data in
            let entry = SimpleEntry(date: Date(), mensaData: data ?? FoodElement.placeholder, configuration: configuration)
            completion(entry)
        } }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        provider.getMensaData(location: configuration.location) { data in
            let timeline = Timeline(entries: [SimpleEntry(date: Date(), mensaData: data ?? FoodElement.placeholder, configuration: configuration)], policy: .atEnd)
            completion(timeline)
        }
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var mensaData: [FoodElement] = FoodElement.placeholder
    let configuration: ConfigurationIntent
}



struct Neuland_Food_WidgetEntryView : View {
    var entry: Provider.Entry
    var displayRestaurantError : Bool {
        return entry.mensaData.first?.meals == nil ? true : false
    }
    var body: some View {
        
        VStack {
            HStack{
                Text("THI \(LocationNames.allCases[entry.configuration.location.rawValue].names)").fontWeight(.bold)
                Spacer()
                
                
            }.padding([.top, .leading, .trailing])
            HStack{
                Text(Helper.widgetDateFormat(dateString: entry.mensaData.first?.timestamp ?? "")).font(.subheadline).fontWeight(.semibold)
                Spacer()
                    
                
            }.padding(.horizontal)
            
            
            ForEach(entry.mensaData.first?.meals ?? []) { index in
                HStack{
                    Text(index.name).font(.footnote).lineLimit(2)
                    Spacer()
                    Text("\(index.prices.student ?? 0.0, specifier: "%.2f")€").font(.footnote).foregroundColor(.secondary)
                }.padding(.top, 0.5)
                
            }.padding(.horizontal)
                
            Spacer()
        }.overlay( Group{ if displayRestaurantError{
            Text("Der Speiseplan ist leer.").foregroundColor(.secondary).font(.footnote)}
           })
        .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
    }
    
}

@main
struct Neuland_Food_Widget: Widget {
    let kind: String = "Neuland_Food_Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Neuland_Food_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mensa Widget")
        .description("Zeigt den aktuellen Speiseplan von Mensa und Reimanns an.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct Neuland_Food_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Neuland_Food_WidgetEntryView(entry: SimpleEntry(date: Date(), mensaData: FoodElement.placeholder, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
