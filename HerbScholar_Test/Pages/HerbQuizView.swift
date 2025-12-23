//
//  TestSystemView.swift
//  HerbScholar_Test
//
//  Created by Yacolate on 2025/12/20.
//

import SwiftUI
import Combine

struct HerbData: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String // 對應 Assets 中的圖片名稱
    let description: String // 藥材簡單描述（可選）
}

class QuizViewModel: ObservableObject {
    private let allHerbs: [HerbData] = [
            HerbData(
                name: "白朮片",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Baizhu_Slices_白朮.jpeg",
                description: "白朮為菊科植物白朮的乾燥根莖，性溫味甘苦，善於健脾益氣、燥濕利水。"
            ),
            HerbData(
                name: "山藥",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Dioscorea_polystachya_Turcz_山藥.jpeg",
                description: "山藥為平補脾肺腎三經的良藥，補而不滯，溫而不燥，亦可作為日常食療。"
            ),
            HerbData(
                name: "白芷",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Dahurian_Angelica_白芷.jpeg",
                description: "白芷氣味芳香，能通竅止痛，是中醫治療面部疾病與鼻病的重要藥材。"
            ),
            HerbData(
                name: "陳皮",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Citri_Reticulatae_Pericarpium_陳皮.jpeg",
                description: "陳皮即橘皮，貯藏年份愈久藥效愈佳，故名。具有調氣、化痰、消食之功。"
            ),
            HerbData(
                name: "何首烏",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Fallopia_multiflora.jpeg",
                description: "何首烏在應用上分為生首烏與制首烏，功用截然不同，臨床補益多用制首烏。"
            ),
            HerbData(
                name: "紅耆",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Hedysarum_Root.jpeg",
                description: "紅耆在台灣與甘肅常用，其功效與黃耆相似，但部分文獻認為其補氣力較黃耆更為醇厚。"
            ),
            HerbData(
                name: "黃耆",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Astragalus_membranaceus.jpeg",
                description: "黃耆被譽為「補氣諸藥之長」，是中醫臨床及食療中最常用的補氣藥物之一。"
            ),
            HerbData(
                name: "甘草",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Licorice_甘草.jpg",
                description: "甘草在中醫處方中出現率最高，有「國老」之稱，既能補益，又能調和藥性。"
            ),
            
            HerbData(
                name: "茯苓",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Poria_茯苓.jpeg",
                description: "茯苓藥性平和，利水而不傷正，是臨床極為常用的補脾利濕藥。"
            ),
            HerbData(
                name: "牛奶榕",
                imageName: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Taiwan_Ficus_牛奶榕.jpeg",
                description: "牛奶榕在台灣民間俗稱「羊奶頭」，被譽為台灣天仙果。"
            )
        ]
    
    @Published var currentQuestionHerb: HerbData?
    @Published var answerOptions: [HerbData] = []
    @Published var score: Int = 0
    @Published var roundCount: Int = 1
    
    // 用於控制 Alert 顯示
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    init() {
        startNewRound()
    }
    
    func startNewRound() {
        guard let correct = allHerbs.randomElement() else { return }
        currentQuestionHerb = correct
        
        let distractors = allHerbs.filter { $0.id != correct.id }.shuffled().prefix(3)
        
        var options = Array(distractors)
        options.append(correct)
        answerOptions = options.shuffled()
    }
    
    func checkAnswer(_ selectedHerb: HerbData) {
        if selectedHerb == currentQuestionHerb {
            score += 10
            alertTitle = "✅ 答對了 ✅"
            alertMessage = "獲得 10 分，這是\(selectedHerb.name)。"
        } else {
            alertTitle = "❌ 答錯了 ❌"
            alertMessage = "正確答案是：\(currentQuestionHerb?.name ?? "")"
        }
        showAlert = true
    }
    
    func resetGame() {
        score = 0
        roundCount = 0
        startNewRound()
    }
}

struct HerbQuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {

                Text("分數: \(viewModel.score)")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 50))
                    .bold()
                    .foregroundStyle(.green)
                    .padding()
                  
                if let question = viewModel.currentQuestionHerb {
                    VStack(spacing: 15) {
                        AsyncImage(url: URL(string: question.imageName)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 300, height: 300)
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: 300, height: 300)
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 300, height: 300)
                                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        Text("請問上圖是哪一種中藥材？")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(viewModel.answerOptions) { herb in
                        Button {
                            viewModel.checkAnswer(herb)
                        } label: {
                            Text(herb.name)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.white)
                                .foregroundColor(.brown)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("下一題")) {
                    viewModel.roundCount += 1
                    viewModel.startNewRound()
                }
            )
        }
    }
}

#Preview {
    HerbQuizView()
}
