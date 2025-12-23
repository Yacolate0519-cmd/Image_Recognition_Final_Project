import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = [
        "All",
        "Exterior-Releasing Herbs",
        "Heat-Clearing Herbs",
        "Tonics",
        "Blood-Activating Herbs",
        "Phlegm-Resolving Herbs"
    ]
    
    var filteredHerbs: [Herb] {
        mockHerbs.filter { herb in
            let matchesSearch = searchText.isEmpty || 
                herb.name.localizedCaseInsensitiveContains(searchText) ||
                herb.scientificName.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == "All" || herb.category.contains(selectedCategory) || (selectedCategory == "Tonics" && herb.category == "Tonics") // Simple matching
            
            // Note: In the mock data I used "Tonics", "Blood-Activating Herbs", "Heat-Clearing Herbs".
            // "Phlegm-Resolving Herbs" and "Exterior-Releasing Herbs" are not in the mock data but kept for UI consistency.
            // The category string in Herb struct is just a string, so exact match or contains.
            // Let's refine the matching logic to be robust.
            
            let categoryMatch: Bool
            if selectedCategory == "All" {
                categoryMatch = true
            } else {
                // Check if the herb's category string matches the selected category
                // In MockData.swift I used: "Tonics", "Blood-Activating Herbs", "Heat-Clearing Herbs"
                // My categories array here matches those.
                // However, "Phlegm-Resolving Herbs" vs "Phlegm-Resolving & Cough-Suppressing Herbs" translation choice.
                // I used "Phlegm-Resolving Herbs" in the array above.
                categoryMatch = herb.category == selectedCategory
            }
            
            return matchesSearch && categoryMatch
        }
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.white)
                
                // Herb Grid
                ScrollView {
                    if filteredHerbs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No herbs found")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredHerbs) { herb in
                                NavigationLink(destination: ResultView(herb: herb)) {
                                    HerbCard(herb: herb)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("中藥材圖庫")
            .searchable(text: $searchText, prompt: "Search herbs...")
        }
    }
}

struct HerbCard: View {
    let herb: Herb
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: herb.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(herb.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(herb.scientificName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(herb.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                    .padding(.top, 4)
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
