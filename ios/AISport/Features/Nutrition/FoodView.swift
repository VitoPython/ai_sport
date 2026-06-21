import SwiftUI
import PhotosUI

@Observable
final class FoodViewModel {
    var pickedItem: PhotosPickerItem?
    var imageData: Data?
    var analysis: FoodAnalysis?
    var isLoading = false
    var errorText: String?

    @MainActor
    func loadImage() async {
        guard let item = pickedItem else { return }
        analysis = nil
        errorText = nil
        if let data = try? await item.loadTransferable(type: Data.self) {
            imageData = data
        }
    }

    @MainActor
    func analyze() async {
        guard let data = imageData, !isLoading else { return }
        isLoading = true
        errorText = nil
        do {
            analysis = try await APIClient.shared.analyzeFood(imageData: data)
        } catch {
            errorText = error.localizedDescription
        }
        isLoading = false
    }
}

struct FoodView: View {
    @State private var vm = FoodViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PhotosPicker(selection: $vm.pickedItem, matching: .images) {
                        Label("Обрати фото страви", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)

                    if let data = vm.imageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button {
                            Task { await vm.analyze() }
                        } label: {
                            Text(vm.isLoading ? "Аналізую…" : "Порахувати калорії")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isLoading)
                    } else {
                        ContentUnavailableView(
                            "Калорії по фото",
                            systemImage: "fork.knife",
                            description: Text("Сфотографуй або обери фото страви — AI оцінить калорії та БЖВ.")
                        )
                        .padding(.top, 40)
                    }

                    if let error = vm.errorText {
                        Text(error).foregroundStyle(.red).font(.caption)
                    }

                    if let analysis = vm.analysis {
                        resultView(analysis)
                    }
                }
                .padding()
            }
            .navigationTitle("Харчування")
            .onChange(of: vm.pickedItem) {
                Task { await vm.loadImage() }
            }
        }
    }

    @ViewBuilder
    private func resultView(_ analysis: FoodAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Разом: \(Int(analysis.totalCalories)) ккал")
                .font(.title3).fontWeight(.semibold)
            Text("Б \(Int(analysis.totalProtein)) г · Ж \(Int(analysis.totalFat)) г · В \(Int(analysis.totalCarbs)) г")
                .font(.subheadline).foregroundStyle(.secondary)

            if !analysis.items.isEmpty {
                Divider()
                ForEach(analysis.items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("\(Int(item.calories)) ккал").foregroundStyle(.secondary)
                    }
                }
            }

            if let notes = analysis.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    FoodView()
}
