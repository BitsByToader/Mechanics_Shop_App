//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import SwiftUI

struct AssignOrderView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    
    @State var orders: [BriefOrder] = []
    @State var mechanics: [Mechanic] = []
    @State var selectedMechanics: [Mechanic] = []
    @State var selectedOrder: BriefOrder?
    @State var mechanicsText: String = ""
    
    func makeSummary() {
        if selectedOrder != nil {
            var text: String = "Comanda \(selectedOrder?.id.uuidString ?? "nul") cu mecanicii "
            for m in selectedMechanics {
                text = text + "\(m.name), "
            }
            mechanicsText = "Sumar: \(text)"
        } else {
            mechanicsText = "Selectati o comanda pentru sumar."
        }
        
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Asigneaza comanda")
            Spacer()
            
            Form {
                List {
                    Section("Comenzi") {
                        ForEach(orders, id:\.id) { order in
                            Button(order.id.uuidString) {
                                selectedOrder = order
                                
                                makeSummary()
                            }
                        }
                    }
                }
                
                List {
                    Section("Mecanici") {
                        ForEach(mechanics) { mechanic in
                            Button(mechanic.name) {
                                if ( selectedMechanics.contains(mechanic) ) {
                                    selectedMechanics.removeAll(where: {$0 == mechanic})
                                } else {
                                    selectedMechanics.append(mechanic)
                                }
                                
                                makeSummary()
                            }
                        }
                    }
                }
                
                Section{
                    Text(mechanicsText)
                }
                
                Button("Confirma") {
                    if ( selectedOrder != nil && !selectedMechanics.isEmpty ) {
                        Task {
                            do {
                                try await selectedOrder?.confirm(to: store.loggedInUser!.id,
                                                                 for: selectedMechanics
                                )
                            } catch {
                                print("ERROR: \(error)")
                            }
                        }
                        dismiss()
                    }
                }
                
                Button("Respinge") {
                    if ( selectedOrder != nil ) {
                        Task {
                            do {
                                try await selectedOrder?.deny()
                            } catch {
                                print("ERROR: \(error)")
                            }
                        }
                        dismiss()
                    }
                }.foregroundStyle(.red)
                
                Button("Dismiss") {
                    dismiss()
                }
            }
        }.onAppear {
            Task {
                do {
                    async let m = try Mechanic.load(for: store.loggedInUser!.id)
                    async let o = try BriefOrder.loadUnmanagedOrders()
                    
                    (mechanics, orders) = try await (m, o)
                } catch {
                    print("ERROR: \(error)")
                }
            }
        }
    }
}
