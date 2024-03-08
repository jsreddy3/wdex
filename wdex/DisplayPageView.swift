//
//  DisplayPageView.swift
//  wdex
//
//  Created by Jaiden Reddy on 3/7/24.
//

import SwiftUI
import Kingfisher

struct DisplayPageView: View {
    let capturedItems: [CapturedItem]
    @State private var currentIndex = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 54, height: 54)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                if !capturedItems.isEmpty {
                    ZStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(radius: 3)
                                        .frame(width: 238, height: 238)
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                                        .frame(width: 238, height: 238)
                                    
                                    if let item = getItemAtIndex(capturedItems, index: currentIndex) {
                                        KFImage(URL(string: item.cropped_image_url))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 222, height: 222)
                                            .cornerRadius(12)
                                            .clipped()
                                    }
                                }
                                Spacer()
                            }
                            
                            HStack {
                                if currentIndex > 0 {
                                    Button(action: {
                                        currentIndex = max(currentIndex - 1, 0)
                                    }) {
                                        Image("flipped_arrow")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 22, height: 29)
                                    }
                                    .padding(.leading, 20)
                                } else {
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                if currentIndex < capturedItems.count - 1 {
                                    Button(action: {
                                        currentIndex = min(currentIndex + 1, capturedItems.count - 1)
                                    }) {
                                        Image("double_arrow")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 22, height: 29)
                                    }
                                    .padding(.trailing, 20)
                                }
                            }
                        }
                        .padding()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text("View Collection")
                                    .font(.custom("Inter-Medium", size: 14))
                                    .foregroundColor(Color(hex: "4D4D4D"))
                                
                                Image("magnify_icon")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                        }
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        Button(action: {
                            // Navigate to the learn more page
                        }) {
                            HStack {
                                Text("Learn More")
                                    .font(.custom("Inter-Medium", size: 14))
                                    .foregroundColor(Color(hex: "4D4D4D"))
                                
                                Image("book_icon")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFF5BF"))
                        .frame(width: 320, height: 270)
                        .overlay(
                            VStack {
                                Text(capturedItems[currentIndex].image_classification)
                                    .font(.custom("Inter-SemiBold", size: 20))
                                    .foregroundColor(.black)
                                    .padding(.top, 0)
                                    .padding(.bottom, 20)
                                
                                VStack(spacing: 10) {
                                    InfoBubble(
                                        icon: "location_icon",
                                        text: "Location: \(capturedItems[currentIndex].location_taken.prefix(20))..."
                                    )
                                    .padding(.bottom, 10)
                                    
                                    InfoBubble(
                                        icon: "calendar_icon",
                                        text: "Date: \(capturedItems[currentIndex].date_added)"
                                    )
                                    .padding(.bottom, 10)

                                    InfoBubble(
                                        icon: "dice_icon",
                                        text: "Probability: \(capturedItems[currentIndex].probability)"
                                    )
                                }
                            }
                            .padding()
                        )
                        .padding()

                                
                    Spacer()
                    
                    Image("nav_divider")
                    
                    BottomNavBar()
                } else {
                    Text("No captured items available.")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
    }
}

struct InfoBubble: View {
    let icon: String
    let text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(height: 40)
            .overlay(
                HStack(spacing: 8) {
                    Image(icon)
                        .resizable()
                        .frame(width: 18, height: 24)
                    
                    Text(text)
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                }
                .padding(.leading)
            )
    }
}

func getItemAtIndex<T>(_ array: [T], index: Int) -> T? {
    guard index >= 0 && index < array.count else {
        return nil
    }
    return array[index]
}
