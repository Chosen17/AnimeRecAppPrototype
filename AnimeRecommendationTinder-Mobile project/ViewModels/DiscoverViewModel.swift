//
// DiscoverViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Discover/Swipe screen.
// Responsible for:
//   - Loading anime cards from Jikan filtered by the user's genre preferences
//   - Managing the card stack (which card is on top, removing swiped cards)
//   - Handling like (swipe right) and skip (swipe left) actions
//   - Saving liked anime to SavedAnimeStorage
//
// The recommendation logic works as follows:
//   1. Load the user's preferred genre IDs from UserPreferencesStorage
//   2. For each genre ID, fetch anime from Jikan's genre endpoint
//   3. Merge all results, remove duplicates, shuffle for variety
//   4. Apply safe content filtering if the user has it enabled
//   5. Present the results as a swipeable card stack
//



import Foundation
import Combine
import SwiftUI


@MainActor
class DiscoverViewModel: ObservableObject{
    
    // Pointer - Published Properties
    
    /// This is the current stack of anime cards that teh user can swipe through
    ///The last item in the array is shown on the top so (rendered last = on top in the Z stack)
    
    @Published var cardStack: [AnimeItem] = []
    
    ///This is true while anime are being fetched(brought over from) Jikan
    
    @Published var isLoading: Bool = false
    
    ///if the loading then fails then an Error message will be shown to the user
    
    @Published var errorMessage: String? = nil
    
    ///Controls the swipe offset of the top card — driven by DragGesture.
    /// if user likes the anime or is interested (postive) = right swipe and negative/dislike/not interested = left swipe
    
    @Published var dragOffset: CGSize = .zero
    
    //Pointer - Private Properties
    
    private let jikanService = JikanService()
    
    /// This here will dictate if the safe content filetr is currently on restricting what conte users can see
    /// to ensure it is acurate have to make sure it actually reads from the UserDefaults and what is in setting so e.g if it is on matches the content that is displayed.
    
    @AppStorage("safe_content_enabled")private var safeContentEnabled: Bool = true
    
    /// Ratings are considered safe when filter is on
    /// and these match the rating scheme which is returned from Jikan
    private let safeRatings: Set<String> = ["G - All Ages", "PG - Children", "PG-13 - Teens 13 or older"]
    
    
    /// This removes the top card from the stack and reset the drag offset
    private func removeTopCard(){
        guard !cardStack.isEmpty else { return }
        cardStack.removeLast()
        dragOffset = .zero
        // this checks if more cards are needed to be fetched
        reloadIfNeeded() 
        
    }
    
    /// Automatically reloads recommendations when the stack
    /// runs low — so the user never hits an empty Discover screen
    /// unless there is a genuine network failure.
    /// Called whenever a card is removed from the stack.
    
    private func reloadIfNeeded(){
        // So when only 3 card remains, SILENTLY refresh more in the background so they will never run out
        if cardStack.count <= 3{
            Task{
                await loadRecommendations()
            }
        }
    }
    
    //Pointer - Public Functions
    
    ///This here will load personalised anime recommendations based on the user's
    ///the genre preferences selected by said user via the questionnaire are saved
    ///But if no gneres are save then it will just showcase the top anime on Jikan.
    
    func loadRecommendations() async{
        isLoading = true
        errorMessage = nil
        cardStack = []
        
        let preferredGenreIDs = UserPreferencesStorage.shared.loadPreferredGenreIDs()
        
        do {
            var results: [AnimeItem] = []
            
            if preferredGenreIDs.isEmpty{
                // This here is if again no preference has been saved via the questionnaire so the user didn't complete it out of choice for example.
                results = try await jikanService.fetchTopAnime()
            } else {
                //the anime for each preferred group will be fetched
                //TaskGroup will be used so all genre requests can run at the same time/parallel to each other
                // so then they dont have to wait for each other to finish before a new request starts.
                try await withThrowingTaskGroup(of: [AnimeItem].self){group in for genreID in preferredGenreIDs.prefix(3) {
                        group.addTask{
                            try await self.jikanService.fetchAnimeByGenre(genreID: genreID)
                        }
                        
                    }
                        
                        for try await genreResults in group{
                            results.append(contentsOf: genreResults)
                        }
                    }
                }
                
                // What we need to ensure is also that duplicate anime are removed because the same anime might have multiple genres so we have to make sure it doesnt appear twice depends on the user's results
                
                var seen = Set<Int>()
                let unique = results.filter { seen.insert($0.id).inserted}
                
                // applying the safe filter is it has been enabled by the user
                
                let filtered = safeContentEnabled
                ? unique.filter {item in guard let rating = item.rating else { return true }; return safeRatings.contains(rating)}
                : unique
                
                // we also have to remove any anime from the popped up recommendation that the user has already saved (This is now) or at least let them now that the have already saved it (this will be later developement or EBI
                
                let savedIDs = Set(SavedAnimeStorage.shared.loadAll().map { $0.id})
                let unsaved = filtered.filter { !savedIDs.contains($0.id)}
                
                // applying a shuffing functionality for variety and then load those into the card stack
                // this will also be reversed so that the index 0 will be at the bottom and whatever the last index is will be at the top (so ascending order basically)
                
                cardStack = unsaved.shuffled()
                
                
            }catch{
                errorMessage = error.localizedDescription
            }
            isLoading = false
            
            
            
            
        }
        /// Called when the user swipes right or taps the like button.
        /// Saves the top card to the watchlist and removes it from the stack.
        
        func LikeTopCard(){
            guard let top = cardStack.last else { return }
            SavedAnimeStorage.shared.save(anime: top)
            removeTopCard()
            
        }
        
        /// Called when the user swipes left or taps the skips button.
        ///  Simply removes the top card without saving it.
        func skipTopCard(){
            removeTopCard()
        }
        
    }
    
    
    
    

