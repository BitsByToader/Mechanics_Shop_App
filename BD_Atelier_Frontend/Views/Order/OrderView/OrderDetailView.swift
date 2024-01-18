//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import SwiftUI

struct OrderDetailView: View {
    @State var name: String
    @State var value: String
    
    var body: some View {
        HStack {
            Text(name)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.gray)
        }
    }
}
