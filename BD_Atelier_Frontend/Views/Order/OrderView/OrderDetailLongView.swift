//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import SwiftUI

struct OrderDetailLongView: View {
    @State var name: String
    @State var value: String
    
    var body: some View {
        VStack {
            Text(name)
            
            Text(value)
                .foregroundStyle(.gray)
        }
    }
}
