import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var store: AppStore
    
    @State var user: User
    @State var orders: [BriefOrder] = []
    
    @State var isLoading: Bool = true
    @State var newOrderSheetDisplayed: Bool = false
    @State var assignOrderSheetDisplayed: Bool = false
    
    func loadData() {
        Task {
            do {
                self.isLoading = true
                self.orders = try await BriefOrder.loadBriefOrders(for: user.id)
                self.isLoading = false
            } catch {
                print("ERROR: \(error)")
            }
        }
    }
    
    var body: some View {
        if isLoading {
            ProgressView("Incarcam comenzile...")
                .navigationTitle("Comenzi")
                .onAppear {
                    loadData()
                }
        } else {
            if orders.isEmpty {
                Text("Nu exista nici o comanda...")
                    .navigationTitle("Comenzi")
                    .toolbar {
                        ToolbarItem {
                            Button("Comanda Noua") {
                                newOrderSheetDisplayed.toggle()
                            }
                        }
                    }.sheet(isPresented: $newOrderSheetDisplayed, onDismiss: {loadData()}) {
                        PlaceOrderView()
                            .environmentObject(store)
                    }
            } else {
                List {
                    ForEach(orders) { order in
                        NavigationLink(value: order, label: {
                            OrdersRowView(order: order)
                        }).disabled(order.state == .waiting || order.state == .denied)
                            .deleteDisabled(!((order.state == .waiting || order.state == .denied || order.state == .pickedup) &&
                                              store.loggedInUser?.type == .manager))
                    }.onDelete { offsets in
                        Task {
                            do {
                                for indice in offsets {
                                    let o = orders.remove(at: indice)
                                    try await o.delete()
                                }
                            } catch {
                                print("ERROR \(error)")
                            }
                        }
                    }
                }.navigationTitle("Comenzi")
                .toolbar {
                    ToolbarItemGroup {
                        Button("Comanda Noua") {
                            newOrderSheetDisplayed.toggle()
                        }
                        
                        if ( store.loggedInUser?.type == UserType.manager ) {
                            Button("Asigneaza Comanda") {
                                assignOrderSheetDisplayed.toggle()
                            }
                        }
                    }
                }
                .sheet(isPresented: $newOrderSheetDisplayed, onDismiss: {loadData()}) {
                    PlaceOrderView()
                        .environmentObject(store)
                }
                .sheet(isPresented: $assignOrderSheetDisplayed, onDismiss: {loadData()}) {
                    AssignOrderView()
                        .environmentObject(store)
                }
                .navigationDestination(for: BriefOrder.self, destination: { order in
                    OrderView(briefOrder: order)
                })
            }
        }
    }
}
