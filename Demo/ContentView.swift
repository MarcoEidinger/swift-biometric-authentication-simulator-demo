import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @State var isKeychainItemCreated = false
    @State var message: String = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Item exists", isOn: $isKeychainItemCreated).disabled(true)
                    Button("Create protected keychain item") {
                        TestData.deleteFromKeychain()
                        isKeychainItemCreated = TestData.insertIntoKeychain(data: "My data stored in the keychain".data(using: .utf8)!)
                    }
                } header: {
                    Text("Setup Keychain")
                }
                
                Section {
                    Button("Access protected keychain item") {
                        message = ""
                        if let data = TestData.readFromKeychain() {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                    }
                } header: {
                    Text("Read The Standard Way")
                }
                
                Section {
                    Button("Access protected keychain item") {
                        Task {
                            message = ""
                            if let data = await localAuthenticationInSimulator(beforeCalling: { TestData.readFromKeychain() }) {
                                message = String(data: data, encoding: .utf8) ?? ""
                            } else {
                                print("No Value")
                            }
                        }
                    }
                } header: {
                    Text("Read Using Decorator")
                }
                
                Section {
                    Text(message)
                } header: {
                    Text("Result")
                }
            }
            .navigationBarTitle(navigationBarTitle)
        }
    }
    
    var navigationBarTitle: String {
#if targetEnvironment(simulator)
        return "Demo in Simulator"
                #else
        return "Demo on Device"
                #endif
    }
}

#Preview {
    ContentView()
}
