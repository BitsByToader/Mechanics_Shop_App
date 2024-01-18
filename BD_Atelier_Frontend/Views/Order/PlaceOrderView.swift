//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import SwiftUI

struct PlaceOrderView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    
    @State var description: String = ""
    @State var date: Date = .now
    @State var loading: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Plaseaza Comanda")
                .bold()
            
            Spacer()
            
            Form {
                TextField("Descrierea problemei", text: $description)
                DatePicker("Data lasarii masinii", selection: $date)
                if !loading {
                    Button("Plaseaza comanda") {
                        Task {
                            do {
                                loading = true
                                try await PlacedOrder(
                                    customer: store.loggedInUser!.id,
                                    description: description,
                                    dropOffDate: date).send()
                                dismiss()
                            } catch {
                                print("ERROR: \(error)")
                            }
                        }
                    }
                    
                    Button("Dismiss") {
                        dismiss()
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView("Trimitem comanda...")
                        Spacer()
                    }
                }
            }
        }
    }
}
