import Foundation
import Combine
import Resolver

@MainActor
class ExerciseLibraryViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var bodyParts: [BodyPart] = []
    @Published var selectedBodyPart: BodyPart = .all
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var errorMessage: String? = nil
    @Published var canLoadMore: Bool = true
    @Published var isLoadingMore: Bool = false
    
    @Injected private var exerciseRepository: ExerciseRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 0
    private let pageSize: Int = 20 // Optimal for production - balance between performance and UX
    
    init() {
        setupSearchDebounce()
    }
    
    // Legacy init for backward compatibility
    init(exerciseRepository: ExerciseRepositoryProtocol) {
        self.exerciseRepository = exerciseRepository
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
            let bodyPartsList = try await exerciseRepository.getBodyPartList()
            var allBodyParts: [BodyPart] = [.all]
            
            // Convert string body parts to enum and filter valid ones
            let validBodyParts = bodyPartsList.compactMap { BodyPart(rawValue: $0) }
                .filter { $0 != .all }
                .sorted { $0.displayName < $1.displayName }
            
            allBodyParts.append(contentsOf: validBodyParts)
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
                self?.resetPagination()
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
            currentPage = 0
            
            let exercisesList = try await fetchExercises(page: 0)
            
            self.exercises = exercisesList
            // Simple pagination logic: if we got a full page, assume there might be more
            self.canLoadMore = exercisesList.count >= pageSize
            
        } catch {
            self.errorMessage = "Failed to load exercises: \(error.localizedDescription)"
            self.exercises = []
            self.canLoadMore = false
            print("❌ Initial load error: \(error)")
        }
        
        isLoading = false
        isSearching = false
    }
    
    func loadMoreExercises() async {
        guard canLoadMore && !isLoadingMore else { return }
        
        do {
            isLoadingMore = true
            currentPage += 1
            
            let newExercises = try await fetchExercises(page: currentPage)
            
            self.exercises.append(contentsOf: newExercises)
            
            // Simple logic: if we got less than a full page, we're done
            self.canLoadMore = newExercises.count >= pageSize
            
        } catch {
            // Reset page on error
            currentPage -= 1
            self.errorMessage = "Failed to load more exercises: \(error.localizedDescription)"
        }
        
        isLoadingMore = false
    }
    
    private func fetchExercises(page: Int) async throws -> [Exercise] {
        let parameters = PaginationParameters(limit: pageSize, offset: page * pageSize)
        var exercisesList: [Exercise]
        
        // Use efficient search when searching
        if !searchText.isEmpty {
            // Use optimized database search instead of client-side filtering
            exercisesList = try await exerciseRepository.searchExercises(query: searchText)
            
            // Apply body part filter to search results if needed
            if selectedBodyPart != .all {
                exercisesList = exercisesList.filter { exercise in
                    exercise.bodyPart == selectedBodyPart
                }
            }
            
            // Apply pagination to search results
            let startIndex = page * pageSize
            let endIndex = min(startIndex + pageSize, exercisesList.count)
            
            if startIndex < exercisesList.count {
                exercisesList = Array(exercisesList[startIndex..<endIndex])
            } else {
                exercisesList = []
            }
            
        } else {
            // When not searching, filter by selected body part with native pagination
            if selectedBodyPart == .all {
                exercisesList = try await exerciseRepository.getAllExercises(parameters: parameters)
            } else {
                exercisesList = try await exerciseRepository.getExercisesByBodyPart(selectedBodyPart.rawValue, parameters: parameters)
            }
        }
        
        return exercisesList
    }
    
    func selectBodyPart(_ bodyPart: BodyPart) {
        selectedBodyPart = bodyPart
        // Clear search when selecting a category
        searchText = ""
        resetPagination()
        Task {
            await loadExercises()
        }
    }
    
    private func resetPagination() {
        currentPage = 0
        canLoadMore = true
        isLoadingMore = false
    }
    
}
