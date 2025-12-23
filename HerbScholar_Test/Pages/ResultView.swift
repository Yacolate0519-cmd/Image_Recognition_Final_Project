import SwiftUI

struct ResultView: View {
    let herb: Herb
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: URL(string: herb.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fit)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(herb.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(herb.scientificName)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(herb.category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                        
                        Text(herb.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Properties
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Properties")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 16) {
                            GridRow {
                                VStack(alignment: .leading) {
                                    Text("Taste")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    Text(herb.taste)
                                        .font(.body)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Nature")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    Text(herb.properties)
                                        .font(.body)
                                }
                            }
                            
                            GridRow {
                                VStack(alignment: .leading) {
                                    Text("Meridians")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    HStack {
                                        ForEach(herb.meridians, id: \.self) { meridian in
                                            Text(meridian)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.green.opacity(0.1))
                                                .foregroundColor(.green)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .gridCellColumns(2)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Functions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Functions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(herb.functions, id: \.self) { function in
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 8)
                                Text(function)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Indications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Indications")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(herb.indications, id: \.self) { indication in
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 8)
                                Text(indication)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Dosage & Precautions
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dosage")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(herb.dosage)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Precautions")
                                .font(.title2)
                                .fontWeight(.bold)
                            ForEach(herb.precautions, id: \.self) { precaution in
                                HStack(alignment: .top) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                        .padding(.top, 4)
                                    Text(precaution)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Scan Next Herb")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                }
                .padding(24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}
