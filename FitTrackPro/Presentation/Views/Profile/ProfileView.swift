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
            .background(.backgroundPrimary)
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
                            colors: [.primaryOrange, .primaryOrange.opacity(0.8)],
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
                        .foregroundColor(.textPrimary)
                    
                    Text("Fitness Enthusiast")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
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
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2), lineWidth: 2)
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
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsSectionView: View {
    @State private var showMyWorkouts = false
    
    let settingsItems = [
        SettingsItem(icon: "dumbbell", title: LocalizedKeys.Profile.myWorkouts.localized, hasChevron: true, action: .myWorkouts),
        SettingsItem(icon: "person.circle", title: LocalizedKeys.Profile.editProfile.localized, hasChevron: true, action: .none),
        SettingsItem(icon: "bell", title: LocalizedKeys.Profile.notifications.localized, hasChevron: true, action: .none),
        SettingsItem(icon: "chart.bar", title: LocalizedKeys.Profile.privacy.localized, hasChevron: true, action: .none),
        SettingsItem(icon: "questionmark.circle", title: LocalizedKeys.Profile.helpSupport.localized, hasChevron: true, action: .none),
        SettingsItem(icon: "info.circle", title: LocalizedKeys.Profile.about.localized, hasChevron: true, action: .none)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedKeys.Profile.settings.localized)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                ForEach(Array(settingsItems.enumerated()), id: \.offset) { index, item in
                    SettingsRowView(item: item) {
                        handleSettingsAction(item.action)
                    }
                    
                    if index < settingsItems.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.2), lineWidth: 2)
            )
        }
        .sheet(isPresented: $showMyWorkouts) {
            MyWorkoutsView()
        }
    }
    
    private func handleSettingsAction(_ action: SettingsAction) {
        switch action {
        case .myWorkouts:
            showMyWorkouts = true
        case .none:
            break
        }
    }
}

enum SettingsAction {
    case myWorkouts
    case none
}

struct SettingsItem {
    let icon: String
    let title: String
    let hasChevron: Bool
    let action: SettingsAction
}

struct SettingsRowView: View {
    let item: SettingsItem
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primaryOrange)
                .frame(width: 20)
            
            Text(item.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if item.hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ProfileView()
}