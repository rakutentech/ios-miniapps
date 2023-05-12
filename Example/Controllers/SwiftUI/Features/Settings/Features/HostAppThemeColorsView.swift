import SwiftUI
import MiniApp

struct HostAppThemeColorsView: View {
    @ObservedObject var viewModel: MiniAppSettingsViewModel
    @State var primaryColor: String = ""
    @State var secondaryColor: String = ""
    @State private var pColor = Color.red
    @State private var sColor = Color.blue
    @State private var alertMessage: MiniAppAlertMessage?

    var body: some View {
        Form {
            Section(header: Text("Enter color as Hex values")) {
                VStack {
                    Text("Primary Color")
                    TextField("Primary Color as(#FFFFFF)", text: $primaryColor)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color("Crimson"), lineWidth: 1)
                        ).keyboardType(.alphabet)
                        .padding()
                    Text("Secondary Color")
                    TextField("Secondary Color(#FFFFFF)", text: $secondaryColor)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color("Crimson"), lineWidth: 1)
                        ).keyboardType(.alphabet)
                        .padding()
                    Text("Note - Please enter only Hex color string including #")
                        .padding()
                        .minimumScaleFactor(0.5)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
           
            
        }
        .onTapGesture {
            dismissKeyboard()
        }
        
        Button {
            trackButtonTap(pageName: pageName, buttonTitle: "Save Theme Colors")
            dismissKeyboard()
            storeHostAppThemeColors()
        } label: {
            Text("Save")
                .font(.system(size: 15, weight: .bold))
                .frame(height: 50)
                .frame(maxWidth: 300)
        }
        .navigationTitle(pageName)
        .foregroundColor(.white)
        .background(Color("Crimson").cornerRadius(10))
        .padding(.all)
        .alert(item: $alertMessage) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Ok")))
        }
        .trackPage(pageName: pageName)
        
    }

    func storeHostAppThemeColors() {
        if $primaryColor.wrappedValue != "" {
            viewModel.store.hostAppThemeColors = HostAppThemeColors(primaryColor: $primaryColor.wrappedValue,
                                                                    secondaryColor: $secondaryColor.wrappedValue == "" ? "#FFFFFF" : $secondaryColor.wrappedValue)
            alertMessage = MiniAppAlertMessage(title: "Success", message: "Theme colors have been stored.")
        } else {
            viewModel.store.hostAppThemeColors = HostAppThemeColors(
                primaryColor: $primaryColor.wrappedValue == "" ? "#FFFFFF" : $primaryColor.wrappedValue,
                secondaryColor: $secondaryColor.wrappedValue == "" ? "#FFFFFF" : $secondaryColor.wrappedValue
            )
            alertMessage = MiniAppAlertMessage(title: "Failure", message: "Theme primary color must not be empty. Default value #FFFFFF will be set.")
        }
    }
}

extension HostAppThemeColorsView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.themeColors", comment: "")
    }
}

struct HostAppThemeColorsView_Previews: PreviewProvider {
    static var previews: some View {
        HostAppThemeColorsView(viewModel: MiniAppSettingsViewModel())
    }
}
