import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Stats Overview
                    ProfileStatsView()
                    
                    // Settings Section
                    SettingsSectionView()
                }
                .padding(.horizontal, 16)
            }
            .background(Color("BackgroundPrimary"))
            .navigationBarHidden(true)
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Avatar and Name
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color("PrimaryOrange"), Color("PrimaryOrange").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Text("H")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text("Hoff Henry")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Fitness Enthusiast")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .padding(.top, 20)
    }
}

struct ProfileStatsView: View {
    var body: some View {
        HStack(spacing: 20) {
            ProfileStatItem(value: "127", label: "Workouts")
            
            Divider()
                .frame(height: 40)
            
            ProfileStatItem(value: "2.5k", label: "Calories")
            
            Divider()
                .frame(height: 40)
            
            ProfileStatItem(value: "45", label: "Days Active")
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
        )
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsSectionView: View {
    let settingsItems = [
        SettingsItem(icon: "person.circle", title: "Edit Profile", hasChevron: true),
        SettingsItem(icon: "bell", title: "Notifications", hasChevron: true),
        SettingsItem(icon: "chart.bar", title: "Privacy", hasChevron: true),
        SettingsItem(icon: "questionmark.circle", title: "Help & Support", hasChevron: true),
        SettingsItem(icon: "info.circle", title: "About", hasChevron: true)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            VStack(spacing: 0) {
                ForEach(Array(settingsItems.enumerated()), id: \.offset) { index, item in
                    SettingsRowView(item: item)
                    
                    if index < settingsItems.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

struct SettingsItem {
    let icon: String
    let title: String
    let hasChevron: Bool
}

struct SettingsRowView: View {
    let item: SettingsItem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("PrimaryOrange"))
                .frame(width: 20)
            
            Text(item.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
            
            if item.hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap
        }
    }
}

#Preview {
    ProfileView()
}