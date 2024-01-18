import SwiftUI

struct OrderView: View {
    @EnvironmentObject var store: AppStore
    
    @State var briefOrder: BriefOrder
    @State var order: Order?
    @State var bill: Bill?
    
    @State var notes: String = ""
    @State var total: Double = 0.0
    
    @State var addItemSheetDisplayed: Bool = false
    
    func loadBill() {
        Task {
            do {
                self.bill = nil
                self.bill = try await order!.loadBill()
                var totalPrice: Double = 0.0
                for item in bill!.items {
                    totalPrice += item.price*Double(item.quantity) +
                            Double(item.labourHours)*item.labourPricePerHour
                }
                self.total = totalPrice
            } catch {
                print("ERROR: \(error)")
            }
        }
    }
    
    var body: some View {
        if (order == nil) {
            ProgressView("Se incarca...")
                .navigationTitle("Comanda")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    Task {
                        do {
                            self.order = try await briefOrder.loadOrder()
                            notes = order?.mechanicNotes ?? ""
                        } catch {
                            print("ERROR: \(error)")
                        }
                    }
                }
        } else {
            List {
                Section("Detalii Comanda") {
                    OrderDetailView(name: "Id", value: order!.id.uuidString)
                    OrderDetailView(name: "Stadiu", value: order!.state.description)
                    
                    OrderDetailView(name: "Client", value: order!.customerName)
                    OrderDetailView(name: "Manager", value: order!.managerName)
                    ForEach(order!.mechanics, id:\.id) { mechanic in
                        OrderDetailView(name: "Mecanic", value: mechanic.name)
                    }
                    
                    OrderDetailView(name: "Data drop-off",
                                    value: order!.dropOffDate?.formatted() ?? "Nestabilit")
                    OrderDetailView(name: "Data inceput",
                                    value: order!.startDate?.formatted() ?? "Nestabilit")
                    OrderDetailView(name: "Data finalizare",
                                    value: order!.finishDate?.formatted() ?? "Nestabilit")
                    
                    OrderDetailLongView(name: "Descrierea Clientului:",
                                        value: order!.description ?? "Fara descriere...")
                    
                    VStack {
                        HStack {
                            Text("Observatii Mecanic:")
                            Spacer()
                        }
                        TextField("Observatii", text: $notes) {
                            Task {
                                do {
                                    try await order?.updateMechanicNotes(notes)
                                } catch {print("ERROR: \(error)")}
                            }
                        }.foregroundStyle(.gray)
                        .disabled(store.loggedInUser!.type != .mechanic)
                    }
                }
                
                Section("Detalii Factura") {
                    if ( bill == nil ) {
                        HStack {
                            Spacer()
                            ProgressView("Incare factura...")
                            Spacer()
                        }
                    } else {
                        OrderDetailView(name: "Id", value: bill!.id.uuidString)
                        OrderDetailView(name: "Facturat", value: bill!.billed ? "Da" : "Nu")
                        OrderDetailView(name: "Platit", value: bill!.payed ? "Da" : "Nu")
                        
                        Spacer()
                        
                        ForEach(bill!.items, id:\.id) { item in
                            OrderItemView(item: item)
                        }
                        
                        Spacer()
                        
                        OrderDetailView(name: "Total: ", value: String(total))
                    }
                }
            }.navigationTitle("Comanda")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadBill()
            }.toolbar {
                ToolbarItemGroup {
                    if ( store.loggedInUser!.type == .mechanic && !(bill?.billed ?? true) ) {
                        Button("Adauga la factura") {
                            addItemSheetDisplayed.toggle()
                        }
                    }
                    
                    if ( store.loggedInUser!.id == order!.managerId &&
                         !(bill?.billed ?? true) &&
                         !(bill?.items.isEmpty ?? true) ) {
                        Button("Incheie si factureaza") {
                            Task {
                                do{
                                    try await bill?.bill()
                                    loadBill()
                                } catch {
                                    print("ERROR: \(error)")
                                }
                            }
                        }
                    }
                    
                    if ( store.loggedInUser!.id == order!.customerId &&
                         (bill?.billed ?? false) &&
                         !(bill?.payed ?? true) ) {
                        Button("Plateste") {
                            Task {
                                do{
                                    try await bill?.pay()
                                    loadBill()
                                } catch {
                                    print("ERROR: \(error)")
                                }
                            }
                        }
                    }
                }
            }.sheet(isPresented: $addItemSheetDisplayed, onDismiss: loadBill) {
                AddBillItemView(order: bill!.id)
            }
        }
    }
}
