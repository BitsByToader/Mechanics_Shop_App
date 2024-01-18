//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 02.01.2024.
//

import SwiftUI

struct AddBillItemView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var order: UUID
    
    @State var name: String = ""
    @State var quantity: Int = 0
    @State var price: Double = 0.0
    @State var hours: Int = 0
    @State var labourPrice: Double = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Adauga produs la factura")
                .bold()
            
            Spacer()
            
            Form {
                TextField("Nume", text: $name)
                
                TextField("Cantitate", value: $quantity, format: .number)
                    .keyboardType(.decimalPad)
                
                TextField("Pret", value: $price, format: .number)
                    .keyboardType(.decimalPad)
                
                TextField("Ore manopera", value: $hours, format: .number)
                    .keyboardType(.decimalPad)
                
                TextField("Pret manopera per ora", value: $labourPrice, format: .number)
                    .keyboardType(.decimalPad)
                
                Button("Salveaza") {
                    Task {
                        do {
                            try await BillItem(id: UUID(),
                                     name: name,
                                     price: price,
                                     quantity: quantity,
                                     labourHours: hours,
                                     labourPricePerHour: labourPrice
                            ).send(for: order)
                            dismiss()
                        } catch {
                            print("ERROR \(error)")
                        }
                    }
                }
                
                Button("Dismiss") {
                    dismiss()
                }
            }
            
            Spacer()
        }
    }
}
