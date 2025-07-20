import Foundation

/// Simple async state management for ViewModels
protocol AsyncViewModel: ObservableObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    
    func handleError(_ error: Error)
    func setLoading(_ loading: Bool)
}

extension AsyncViewModel {
    func handleError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
    }
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            errorMessage = nil
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}