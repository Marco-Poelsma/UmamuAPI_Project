import SwiftUI

struct SparkListView: View {

    @State private var sparks: [Spark] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""

    // MARK: - Filtering

    var filteredSparks: [Spark] {
        if searchText.isEmpty {
            return sparks
        } else {
            return sparks.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var statSparks: [Spark] {
        filteredSparks.filter { $0.type == .stat }
    }

    var aptitudeSparks: [Spark] {
        filteredSparks.filter { $0.type == .aptitude }
    }

    var skillSparks: [Spark] {
        filteredSparks.filter { $0.type == .skill }
    }

    var uniqueSkillSparks: [Spark] {
        filteredSparks.filter { $0.type == .uniqueSkill }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Search Bar
                    let radius: CGFloat = 20

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Buscar spark...", text: $searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(radius)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                    // MARK: - Content

                    if isLoading {
                        Spacer()
                        ProgressView("Cargando sparks...")
                        Spacer()
                    }
                    else if let errorMessage = errorMessage {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    else {
                        List {

                            sparkSection(title: "📊 Stat", sparks: statSparks)
                            sparkSection(title: "🏇 Aptitude", sparks: aptitudeSparks)
                            sparkSection(title: "⚔️ Skill", sparks: skillSparks)
                            sparkSection(title: "🌟 Unique Skill", sparks: uniqueSkillSparks)

                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("✨ Sparks")
        }
        .onAppear {
            loadSparks()

            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
        }
    }

    // MARK: - Section Builder

    @ViewBuilder
    private func sparkSection(title: String, sparks: [Spark]) -> some View {
        if !sparks.isEmpty {
            Section(
                header: Text(title)
                    .font(.headline)
                    .textCase(nil)
            ) {
                ForEach(sparks) { spark in
                    VStack(alignment: .leading, spacing: 6) {

                        Text(spark.name)
                            .font(.headline)

                        Text(spark.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Load

    private func loadSparks() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sparks):
                    self.sparks = sparks
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
