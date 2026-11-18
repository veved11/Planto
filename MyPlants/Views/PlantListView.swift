import SwiftUI

struct PlantListView: View {
    private enum ReminderSheet: Identifiable {
        case add
        case edit(PlantReminder)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let plant):
                return plant.id.uuidString
                
            }
        }
    }

    @StateObject private var viewModel = PlantListViewModel()
 
    @Environment(\.scenePhase) private var scenePhase

    @State private var activeSheet: ReminderSheet?
    @State private var isShowingAllPlants = false
    @AppStorage("hasCreatedFirstReminder")
    private var hasCreatedFirstReminder = false
    private var areAllPlantsComplete: Bool {
        !viewModel.plants.isEmpty &&
        viewModel.completedCount == viewModel.plants.count
    }
    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            AppColors.background
                .ignoresSafeArea()

            if hasCreatedFirstReminder {

                VStack(spacing: 0) {

                    screenHeader

                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(height: 1)

                    if viewModel.plants.isEmpty {
                        emptyState
                    } else if
                    areAllPlantsComplete && !isShowingAllPlants {
                        allDoneState
                    } else {
                        plantsContent
                    }
                }

                addButton

            } else {

                StartPlantJourneyView {
                    activeSheet = .add
                }
            }
        }
        .sheet(item: $activeSheet) { sheet
            in
           
            switch sheet {

            case .add:

                AddReminderView(
                    onSave: { reminder in
                        viewModel.add(reminder)
                        hasCreatedFirstReminder = true
                        isShowingAllPlants = false
                    }
                )

            case .edit(let plant):

                AddReminderView(
                    plant: plant,
                    onSave: { updatedPlant in
                      
                        viewModel.update(plant, with: updatedPlant)
                    },
                    onDelete: { plantToDelete in
                        viewModel.delete(plantToDelete)
                    }
                )
                .id(plant.id)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                viewModel.resetDailyCompletionsIfNeeded()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var screenHeader: some View {

        HStack {

            Text("My Plants 🌱")
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColors.primaryText)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 38)
        .padding(.bottom, 18)
    }

    // MARK: - Empty State

    private var emptyState: some View {

        VStack {

            Spacer()

            Text("No reminders set yet..")
                .font(AppTypography.emptyState)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - All Done State

    private var allDoneState: some View {

        VStack(spacing: 12) {

            Spacer()

            Image("PlantMascotWinking")
                .resizable()
                .scaledToFit()
                .frame(width: 219, height: 227)
                .background(
                    Color(hex: 0x14141A).opacity(0.58),
                    in: Circle()
                )
                .accessibilityHidden(true)

            Text("All Done! 🎉")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.primaryText)

            Text("All Reminders Completed")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.secondaryText)

            Button("View All Plants") {
                isShowingAllPlants = true
                                    }
            .buttonStyle(AppButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Plants Content

    private var plantsContent: some View {
        VStack(spacing: 0) {

            ProgressBarView(
              
                completedCount: viewModel.completedCount,
                totalCount: viewModel.plants.count
            )
            .padding(.top, 28)
            .padding(.bottom, 24)

            List {

                ForEach(viewModel.plants) { plant in
                    PlantRowView(
                        plant: plant,
                        onEdit: {
                            isShowingAllPlants = false
                            activeSheet = .edit(plant)
                        },
                        onToggleDone: {
                            viewModel.toggleDone(for: plant)
                            isShowingAllPlants = false
                        }
                    )
                    .padding(.top, 15)
                    .padding(.bottom, 11)
                    .listRowInsets(
                        EdgeInsets(
                            top: 0,
                            leading: 16,
                            bottom: 0,
                            trailing: 16
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        AppColors.background
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(AppColors.divider)
                                    .frame(height: 1)
                            }
                    )
                }
                .onDelete { offsets in
                    let plantsToDelete = offsets.map {
                        viewModel.plants[$0]
                    }
                    plantsToDelete.forEach(viewModel.delete)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Add Button

    private var addButton: some View {

        Button {
            isShowingAllPlants = false
            activeSheet = .add
        } label: {
            addButtonIcon
        }
        .buttonStyle(.plain)
        .padding(.trailing, 24)
        .padding(.bottom, 38)
        .accessibilityLabel("Add plant reminder")
    }

    @ViewBuilder
    private var addButtonIcon: some View {

        if #available(iOS 26.0, *) {

            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .glassEffect(
                    .regular
                        .tint(Color(hex: 0x338069))
                        .interactive(),
                    in: Circle()
                )

        } else {

            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Color(hex: 0x338069),
                    in: Circle()
                )
        }
    }
}

#Preview {
    PlantListView()
}
