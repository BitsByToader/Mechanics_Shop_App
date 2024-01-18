import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    
    @State var registerSheetDisplayed: Bool = false
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Form(content: {
            TextField("Utilizator", text: $username)
            
            SecureField("Parola", text: $password)
            
            Button("Log In", action: {
                Task {
                    do {
                        let user: User = try await User(username: username, password: password).logIn()
                        
                        if ( user.loggedIn() ) {
                            store.loggedInUser = user
                            store.navPath.append(user)
                        } else {
                            // logging in failed...
                            // TODO: Notify user in UI that credentials are incorrect 
                        }
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }).navigationDestination(for: User.self, destination: { user in
                OrdersView(user: user)
            }).toolbar {
                ToolbarItem {
                    Button("Inregistrare") {
                        registerSheetDisplayed.toggle()
                    }
                }
            }.sheet(isPresented: $registerSheetDisplayed) {
                RegisterView()
            }
        })
    }
}
