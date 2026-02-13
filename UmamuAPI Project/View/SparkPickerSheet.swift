import SwiftUI

struct SparkPickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode

    @State private var sparks: [Spark] = []
    @State private var searchText = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    @Binding var selectedIDs: Set<Int>

    let onSave: () -> Void
    let onCancel: () -> Void

    // MARK: - Filtering
    var filteredSparks: [Spark] {
        if searchText.isEmpty {
            return sparks
        } else {
            return sparks.filter {
                $0.name.lowercased().contains(searchText.lowercased())
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
    
    // MARK: - Validation
    private var selectedStats: [Spark] {
        sparks.filter { selectedIDs.contains($0.id) && $0.type == .stat }
    }
    
    private var selectedAptitudes: [Spark] {
        sparks.filter { selectedIDs.contains($0.id) && $0.type == .aptitude }
    }
    
    private var selectedUniqueSkills: [Spark] {
        sparks.filter { selectedIDs.contains($0.id) && $0.type == .uniqueSkill }
    }
    
    private var isValid: Bool {
        // DEBE haber 1 spark de Stat
        guard selectedStats.count == 1 else {
            validationMessage = "Debes seleccionar exactamente 1 spark de Stat"
            return false
        }
        
        // DEBE haber 1 spark de Aptitude
        guard selectedAptitudes.count == 1 else {
            validationMessage = "Debes seleccionar exactamente 1 spark de Aptitude"
            return false
        }
        
        // DEBE haber entre 0 y 3 sparks de unique skill
        guard selectedUniqueSkills.count >= 0 && selectedUniqueSkills.count <= 3 else {
            validationMessage = "Debes seleccionar entre 0 y 3 sparks de Unique Skill"
            return false
        }
        
        return true
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                contentList
            }
        }
        .navigationBarTitle("Select Sparks", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Cancel") {
                onCancel()
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                if isValid {
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showValidationAlert = true
                }
            }
        )
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text("Selección inválida"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            load()
            
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().tableFooterView = UIView()
        }
    }
    
    // MARK: - Subviews
    private var searchBar: some View {
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
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    private var contentList: some View {
        VStack(spacing: 0) {
            List {
                if !statSparks.isEmpty {
                    statSection
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                if !aptitudeSparks.isEmpty {
                    aptitudeSection
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                if !skillSparks.isEmpty {
                    skillSection
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                if !uniqueSkillSparks.isEmpty {
                    uniqueSkillSection
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .environment(\.defaultMinListRowHeight, 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var statSection: some View {
        Section(header:
            HStack {
                Text("STAT")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(statSparks.count) sparks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Indicador de selección
                Text("(\(selectedStats.count)/1)")
                    .font(.caption)
                    .foregroundColor(selectedStats.count == 1 ? .green : .red)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color.white)
        ) {
            ForEach(Array(statSparks.enumerated()), id: \.element.id) { index, spark in
                sparkRow(spark: spark, index: index, category: statSparks)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
    }
    
    private var aptitudeSection: some View {
        Section(header:
            HStack {
                Text("APTITUDE")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(aptitudeSparks.count) sparks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Indicador de selección
                Text("(\(selectedAptitudes.count)/1)")
                    .font(.caption)
                    .foregroundColor(selectedAptitudes.count == 1 ? .green : .red)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color.white)
        ) {
            ForEach(Array(aptitudeSparks.enumerated()), id: \.element.id) { index, spark in
                sparkRow(spark: spark, index: index, category: aptitudeSparks)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
    }
    
    private var skillSection: some View {
        Section(header:
            HStack {
                Text("SKILL")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(skillSparks.count) sparks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color.white)
        ) {
            ForEach(Array(skillSparks.enumerated()), id: \.element.id) { index, spark in
                sparkRow(spark: spark, index: index, category: skillSparks)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
    }
    
    private var uniqueSkillSection: some View {
        Section(header:
            HStack {
                Text("UNIQUE")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(uniqueSkillSparks.count) sparks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Indicador de selección
                Text("(\(selectedUniqueSkills.count)/3)")
                    .font(.caption)
                    .foregroundColor(selectedUniqueSkills.count <= 3 ? .green : .red)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color.white)
        ) {
            ForEach(Array(uniqueSkillSparks.enumerated()), id: \.element.id) { index, spark in
                sparkRow(spark: spark, index: index, category: uniqueSkillSparks)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
    }
    
    // MARK: - Spark Row
    private func sparkRow(spark: Spark, index: Int, category: [Spark]) -> some View {
        VStack(spacing: 0) {
            // Botón que ocupa toda el área
            Button(action: {
                toggleSelection(spark.id)
            }) {
                HStack {
                    Text(spark.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if selectedIDs.contains(spark.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .padding(4) // 🔥 Reducido de 6 a 4
                            .background(Color.blue)
                            .clipShape(Circle())
                            .font(.system(size: 10, weight: .bold)) // 🔥 Reducido de 12 a 10
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Divider solo entre elementos
            if index < category.count - 1 {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(
            index == 0 ? 12 : 0,
            corners: [.topLeft, .topRight]
        )
        .cornerRadius(
            index == category.count - 1 ? 12 : 0,
            corners: [.bottomLeft, .bottomRight]
        )
    }

    // MARK: - Selection
    private func toggleSelection(_ id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    // MARK: - Load
    private func load() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            if case let .success(data) = result {
                DispatchQueue.main.async {
                    sparks = data
                }
            }
        }
    }
}
