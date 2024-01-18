//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import SwiftUI

struct OrderItemView: View {
    @State var item: BillItem
    
    var body: some View {
        HStack {
            VStack {
                Text("Piesa: \(item.name)")
                Text("Manopera: ")
            }
            
            
            Spacer()
            
            VStack {
                Text("\(item.quantity) X \(item.price) = \(item.price*Double(item.quantity))")
                Text("\(item.labourHours) X \(item.labourPricePerHour) = \(item.labourPricePerHour*Double(item.labourHours))")
            }.foregroundStyle(.gray)
        }
    }
}
