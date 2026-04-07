//
// SwipeCardView.swift
// AnimeRecommendationTinder-Mobile project
//
// A single anime card displayed in the swipe stack on DiscoverView.
// Shows the cover image as a full-card background with a gradient
// overlay at the bottom containing the title, score and genres.
//
// Deliberately designed differently from AnimeCardView (the horizontal
// list card on HomeView) — the swipe card is portrait/poster-style,
// filling most of the screen height for a more immersive feel.
//



import SwiftUI

struct SwipeCardView: View{
    
    let anime: AnimeItem
    
    var body: some View {
        ZStack(alignment: .bottom){
            
            // Pointer - Cover image (full card background)
            AsyncImage(url: URL(string:
                                    anime.images.jpg.largeImageUrl ?? anime.images.jpg.imageUrl ?? "")){
                phase in switch phase { case .empty: RoundedRectangle(cornerRadius: 20).fill(Color.secondary.opacity(0.2)).overlay(ProgressView())case .success(let image): image .resizable() .aspectRatio(contentMode: .fill)case .failure: RoundedRectangle(cornerRadius: 20).fill(Color.secondary.opacity(0.2)).overlay(Image(systemName: "photo").font(.system(size:48)).foregroundStyle(.secondary))
                @unknown default:
                    EmptyView()
                }
            }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Pointer - Gradient Overlay
            // making it so that there is a dark gradient at the bottom
            // so that the white text will be readable
            // over any cover image colour
            
            LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .center, endPoint: .bottom)
            
                .clipShape (RoundedRectangle(cornerRadius: 20))
            
            
            // Pointer - Information section
            VStack(alignment: .leading, spacing: 8){
                
                // This here will be the title
                Text(anime.titleEnglish ?? anime.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                //The rating score it has been given
                //and the number of episodes that it has
                
                HStack(spacing: 12){
                    if let score = anime.score{
                        Label("\(String(format: "$.1f", score))", systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundStyle(.yellow)
                    }
                    
                    if let episodes = anime.episodes{
                        Text("\(episodes) eps")
                            .font(.subheadline)
                            .foregroundStyle(.yellow)
                    }
                    if let status = anime.status {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                //Here are the genre atges which will have white text
                // the background will be semi-transparent
                
                if !anime.genres.isEmpty{
                    HStack(spacing: 6){
                        ForEach(anime.genres.prefix(3), id: \.malId) { genre in Text(genre.name).font(.caption).padding(.horizontal, 8).padding(.vertical, 4).background(.white.opacity(0.2)).foregroundStyle(.white).clipShape(Capsule())}
                    }
                }
                
                
                
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            
        }
        .frame(height: 520)
        .shadow(color: .black.opacity(0.2), radius: 8, x:0, y:4)
        
    }
    
}
