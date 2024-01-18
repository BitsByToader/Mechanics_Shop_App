//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 07.01.2024.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Inregistrare")
                .bold()
            
            Spacer()
            
            Form {
                TextField("Nume", text: $name)
                TextField("Utilizator", text: $username)
                SecureField("Parola", text: $password)
                Button("Inregistrare") {
                    Task {
                        do {
                            try await User.register(name: name,
                                                    username: username,
                                                    password: password
                            )
                            dismiss()
                        } catch {
                            print("ERROR: \(error)")
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
