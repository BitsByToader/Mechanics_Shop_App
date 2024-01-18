import SwiftUI

struct OrdersRowView: View {
    @State var order: BriefOrder
    
    var body: some View {
        VStack {
            HStack {
                Text("Comanda:")
                Spacer()
                Text(order.id.uuidString)
                    .foregroundStyle(.gray)
            }
            
            HStack {
                Text("Stare:")
                Spacer()
                Text(order.state.description)
                    .foregroundStyle(order.state.color)
            }
        }
    }
}
