//
//  ProfileView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text(User.MOCK_USER.initial  )
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color(.systemGray))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(User.MOCK_USER.fullName)
                            .font(.headline)
                            .padding(.top,4)
                        Text(User.MOCK_USER.email )
                            .font(.footnote)
                            .foregroundColor(.gray  )
                    }
                    .padding(.leading)   
                }
            }
            
            Section("General") {
                HStack {
                    SettingRowView(
                        imageName: "gear" ,
                        title: "Version",
                        tintColor: Color(.systemGray))
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray  )
                }
            }
            
            Section("Account"){
                Button {
                    print("Sign out....")
                } label: {
                    SettingRowView(
                        imageName: "arrow.left.circle.fill" ,
                        title: "Sign out",
                        tintColor: .red)
                }

                Button {
                    print("Deleting account....")
                } label: {
                    SettingRowView(
                        imageName: "xmark.circle.fill" ,
                        title: "Delete Account",
                        tintColor: .red)
                }

            }
        }
    }
}

#Preview {
    ProfileView()
}
