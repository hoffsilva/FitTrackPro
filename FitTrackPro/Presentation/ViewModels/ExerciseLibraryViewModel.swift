import Foundation
import Combine

@MainActor
class ExerciseLibraryViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var bodyParts: [String] = []
    @Published var selectedBodyPart: String = "all"
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var errorMessage: String? = nil
    
    private let exerciseService: ExerciseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    init(exerciseService: ExerciseServiceProtocol? = nil) {
        self.exerciseService = exerciseService ?? ExerciseService()
        setupSearchDebounce()
    }
    
    func loadInitialData() {
        Task {
            await loadBodyParts()
            await loadExercises()
        }
    }
    
    func loadBodyParts() async {
        do {
            let bodyPartsList = try await exerciseService.getBodyPartList()
            var allBodyParts = ["all"]
            allBodyParts.append(contentsOf: bodyPartsList.sorted())
            self.bodyParts = allBodyParts
        } catch {
            self.errorMessage = "Failed to load body parts: \(error.localizedDescription)"
        }
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.loadExercises()
                }
            }
            .store(in: &cancellables)
    }
    
    
    func loadExercises() async {
        do {
            isLoading = true
            isSearching = !searchText.isEmpty
            errorMessage = nil
            
            let parameters = PaginationParameters(limit: 200, offset: 0)
            var exercisesList: [Exercise]
            
            // If searching, always load all exercises and filter by search term
            if !searchText.isEmpty {
                exercisesList = try await exerciseService.getAllExercises(parameters: parameters)
                exercisesList = exercisesList.filter { exercise in
                    exercise.name.localizedCaseInsensitiveContains(searchText) ||
                    exercise.bodyPart.localizedCaseInsensitiveContains(searchText) ||
                    exercise.target.localizedCaseInsensitiveContains(searchText) ||
                    exercise.equipment.localizedCaseInsensitiveContains(searchText)
                }
            } else {
                // When not searching, filter by selected body part
                if selectedBodyPart == "all" {
                    exercisesList = try await exerciseService.getAllExercises(parameters: parameters)
                } else {
                    exercisesList = try await exerciseService.getExercisesByBodyPart(selectedBodyPart, parameters: parameters)
                }
            }
            
            self.exercises = exercisesList
            
        } catch {
            self.errorMessage = "Failed to load exercises: \(error.localizedDescription)"
            self.exercises = []
        }
        
        isLoading = false
        isSearching = false
    }
    
    func selectBodyPart(_ bodyPart: String) {
        selectedBodyPart = bodyPart
        // Clear search when selecting a category
        searchText = ""
        Task {
            await loadExercises()
        }
    }
}
