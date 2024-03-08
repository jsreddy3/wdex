//
//  CollectionsView.swift
//  worlddex
//
//  Created by Jaiden Reddy on 3/6/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct CapturedItem: Identifiable, Equatable {
    let id: UUID
    let user_id: String
    let date_added: String
    let location_taken: String
    let details: String
    let probability: String
    let image_classification: String
    let cropped_image_url: String
    let image_url: String
}

class CollectionsViewModel: ObservableObject {
    @Published var capturedItems: [CapturedItem] = []
    @Published var selectedSortOrder = "Time Ascending"

    
    func fetchCapturedItems(userId: String) {
        let url = URL(string: Constants.baseURL + Constants.Endpoints.userImages + "?user_id=\(userId)")!

        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imagesData = jsonResult["images"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.capturedItems = imagesData.map { imageData in
                            CapturedItem(
                                id: UUID(),
                                user_id: imageData["user_id"] as? String ?? "",
                                date_added: imageData["date_added"] as? String ?? "",
                                location_taken: imageData["location_taken"] as? String ?? "",
                                details: imageData["details"] as? String ?? "",
                                probability: imageData["probability"] as? String ?? "",
                                image_classification: imageData["image_classification"] as? String ?? "",
                                cropped_image_url: imageData["cropped_image_url"] as? String ?? "",
                                image_url: imageData["image_url"] as? String ?? ""
                            )
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sortCapturedItems() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        capturedItems.sort { item1, item2 in
            guard let date1 = dateFormatter.date(from: item1.date_added),
                  let date2 = dateFormatter.date(from: item2.date_added) else {
                return false
            }
            
            if selectedSortOrder == "Time Ascending" {
                return date1 < date2
            } else {
                return date1 > date2
            }
        }
    }
    
    func updateCapturedItems(_ items: [CapturedItem]) {
        DispatchQueue.main.async {
            self.capturedItems = items
        }
    }
}

struct CollectionsView: View {
    @StateObject private var viewModel = CollectionsViewModel()
    @State private var draggedItem: CapturedItem?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            VStack {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 54, height: 54)
                            .foregroundColor(.yellow)
                        
                        Spacer()
                    }
                    .padding(.bottom, 10) // Adjust the spacing between the logo and "Your Collection"
                    
                    HStack {
                        Spacer()
                        
                        Text("Your Collection")
                            .font(.custom("Inter-Medium", size: 22))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20) // Adjust the horizontal spacing for the logo and "Your Collection"
                
            HStack {
                Menu {
                    Picker(selection: $viewModel.selectedSortOrder, label: Text("Sorting Options")) {
                        Text("Time Ascending").tag("Time Ascending")
                        Text("Time Descending").tag("Time Descending")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.selectedSortOrder) { _ in
                        viewModel.sortCapturedItems()
                    }
                } label: {
                    HStack {
                        Text("Sort By")
                            .font(.custom("Inter-Medium", size: 16))
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                        
                        Image("quill_hamburger")
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 25)
            .padding(.top, 1)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.capturedItems) { item in
                        CapturedItemCell(item: item)
                            .onDrag {
                                self.draggedItem = item
                                return NSItemProvider(object: item.id.uuidString as NSString)
                            }
                            .onDrop(of: [.plainText], delegate: DropViewDelegate(item: item, viewModel: viewModel, draggedItem: $draggedItem))
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.top, 15)
            }
            
            Button(action: {
                // Navigate to the display page view
            }) {
                NavigationLink(destination: DisplayPageView(capturedItems: viewModel.capturedItems)) {
                    Image("select_order")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 44)
                }
            }
            
            Image("nav_divider")
        }
        .onAppear {
            viewModel.fetchCapturedItems(userId: "dog")
        }
    }
    
    func sortCapturedItems(_ item1: CapturedItem, _ item2: CapturedItem, by sortOrder: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        guard let date1 = dateFormatter.date(from: item1.date_added),
              let date2 = dateFormatter.date(from: item2.date_added) else {
            return false
        }
        
        if sortOrder == "Time Ascending" {
            return date1 < date2
        } else {
            return date1 > date2
        }
    }
}

struct CapturedItemCell: View {
    let item: CapturedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.image_classification)
                .font(.custom("Inter-Bold", size: 12))
                .lineLimit(1)
                .bold()
                .padding(.top, 20)
                .padding(.bottom, 0)
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                KFImage(URL(string: item.cropped_image_url))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                    .padding(.trailing, 0)
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 4) {
                        Image("location_icon")
                        Text(item.location_taken)
                            .font(.custom("Inter-Regular", size: 12))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.black)
                    }
                    
                    HStack(spacing: 4) {
                        Image("calendar_icon")
                        Text(item.date_added)
                            .font(.custom("Inter-Regular", size: 12))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.black)
                    }
                    
                    HStack(spacing: 4) {
                        Image("dice_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Text(item.probability)
                            .font(.custom("Inter-Regular", size: 12))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 0)
            }
        }
        .frame(width: 143, height: 108)
        .padding()
        .background(Color(hex: "FFF5BF"))
        .cornerRadius(12)
    }
}

struct BottomNavBar: View {
    var body: some View {
        HStack {
            // Add your nav bar items here
            Image("pokedex_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Spacer()
            
            Image("camera_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Spacer()
            
            Image("social_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Spacer()
            
            Image("profile_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
        }
        .padding(.leading, 40)
        .padding(.trailing, 40)
    }
}

class DropViewDelegate: DropDelegate {
    let item: CapturedItem
    let viewModel: CollectionsViewModel
    @Binding var draggedItem: CapturedItem?
    
    init(item: CapturedItem, viewModel: CollectionsViewModel, draggedItem: Binding<CapturedItem?>) {
        self.item = item
        self.viewModel = viewModel
        self._draggedItem = draggedItem
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print("performDrop called")
        guard let draggedItem = self.draggedItem else {
            print("Dragged item is nil")
            return false
        }
        
        if let draggedIndex = viewModel.capturedItems.firstIndex(of: draggedItem),
           let destinationIndex = viewModel.capturedItems.firstIndex(of: item),
           draggedIndex != destinationIndex {
            var updatedItems = viewModel.capturedItems
            updatedItems.move(fromOffsets: IndexSet(integer: draggedIndex), toOffset: destinationIndex > draggedIndex ? destinationIndex + 1 : destinationIndex)
            viewModel.updateCapturedItems(updatedItems)
            self.draggedItem = nil
            return true
        }
        
        return false
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
