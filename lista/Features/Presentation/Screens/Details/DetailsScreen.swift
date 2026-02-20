//
//  DetailsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct DetailsScreen: View {
    let listaId: String
    let listaTitle: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: NavigationCoordinator

    @StateObject private var viewModel: DetailsViewModel
    @State private var presentation: DetailsScreenPresentation? = nil
    @State private var detailsToPresent: ListaItemUiModel? = nil

    init(
        viewModel: DetailsViewModel = InstanceKeeper.shared
            .provideDetailsViewModel(),
        listaId: String,
        listaTitle: String
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.listaId = listaId
        self.listaTitle = listaTitle
    }

    var body: some View {
        DetailsContentView(
            updatedAt: viewModel.updatedAt,
            isArchived: viewModel.isArchived,
            isCompleted: viewModel.isCompleted,
            isEditEnabled: viewModel.canEdit,
            items: viewModel.items,
            onAction: { action in
                switch action {
                case .onAddItem:
                    coordinator.push(
                        .insertItem(listId: self.listaId, itemId: nil)
                    )
                case .onToggleItemState(let changedItem):
                    viewModel.onToogleItemState(item: changedItem)

                case .onUpdateItem(let item):
                    coordinator.push(
                        .insertItem(listId: self.listaId, itemId: item.id)
                    )
                case .onDeleteItem(let item):
                    viewModel.onDeleteItem(itemId: item.id)
                case .onTapItem(let item):
                    detailsToPresent = item
                }
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(listaTitle)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                DetailsContextMenuView(
                    isCompleted: viewModel.isCompleted,
                    isArquived: viewModel.isArchived,
                    onAction: { action in
                        switch action {
                        case .archive:
                            presentation = .confirmArchive
                        case .undoArchive:
                            viewModel.setArchiveState(state: false)
                        case .delete:
                            presentation = .confirmDelete
                        case .complete:
                            presentation = .confirmComplete
                        case .undoComplete:
                            viewModel.setCompletedState(state: false)
                        }
                    }
                )

                Button(action: {
                    coordinator.push(.insertItem(listId: listaId, itemId: nil))
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(
                    LocalizedStringKey("accessibility.add_item")
                )
                .disabled(!viewModel.canEdit)
            }
        }
        .alert(
            LocalizedStringKey("alert.delete_list.title"),
            isPresented: .constant(isConfirmDeletePresented),
        ) {
            Button(
                LocalizedStringKey("alert.button.delete"),
                role: .destructive
            ) {
                viewModel.onDeleteList()
                presentation = nil
            }
            Button(LocalizedStringKey("alert.button.cancel"), role: .cancel) {
                presentation = nil
            }
        } message: {
            Text(LocalizedStringKey("alert.delete_list.message"))
        }
        .alert(
            LocalizedStringKey("alert.archive_list.title"),
            isPresented: .constant(isConfirmArchivePresented),
            actions: {
                Button(
                    LocalizedStringKey("alert.button.archive"),
                    role: .destructive
                ) {
                    viewModel.setArchiveState(state: true)
                    presentation = nil
                }
                Button(LocalizedStringKey("alert.button.cancel"), role: .cancel)
                {
                    presentation = nil
                }
            },
            message: {
                Text(LocalizedStringKey("alert.archive_list.message"))
            }
        )
        .alert(
            LocalizedStringKey("alert.complete_list.title"),
            isPresented: .constant(isConfirmCompletePresented),
            actions: {
                Button(
                    LocalizedStringKey("alert.button.complete"),
                    role: .destructive
                ) {
                    viewModel.setCompletedState(state: true)
                    presentation = nil
                }
                Button(LocalizedStringKey("alert.button.cancel"), role: .cancel)
                {
                    presentation = nil
                }
            },
            message: {
                Text(LocalizedStringKey("alert.complete_list.message"))
            }
        )
        .sheet(
            isPresented: Binding(
                get: {
                    detailsToPresent != nil
                },
                set: { isPresented in
                    if !isPresented {
                        detailsToPresent = nil
                    }
                }
            )
        ) {
            if let itemDetails = detailsToPresent {
                ItemDetailsView(
                    item: itemDetails,
                    onUpdate: {
                        detailsToPresent = nil
                        coordinator.push(
                            .insertItem(
                                listId: self.listaId,
                                itemId: itemDetails.id
                            )
                        )
                    },
                    onToggle: {
                        viewModel.onToogleItemState(item: itemDetails)
                        detailsToPresent = nil
                    },
                    enableEdit: viewModel.canEdit,
                    onTapUrl: { url in
                        guard let browserUrl = URL(string: url) else { return }
                        if UIApplication.shared.canOpenURL(browserUrl) {
                            UIApplication.shared.open(browserUrl)
                            return
                        }
                    }
                )
            }
        }
        .task {
            viewModel.onAppear(listaId: listaId)
        }
        .onChange(of: self.viewModel.events) { _, newValue in
            if let event = newValue {
                self.handleEvent(event: event)
            }
        }
    }

    private func handleEvent(event: DetailsViewModel.Events) {
        switch event {

        case .deleteSuccess:
            dismiss()
        }
    }
}

enum DetailsScreenPresentation {
    case confirmDelete
    case confirmArchive
    case confirmComplete
}

// MARK: - Extensions
extension DetailsScreen {
    private var isConfirmDeletePresented: Bool {
        if case .confirmDelete = presentation {
            return true
        }
        return false
    }

    private var isConfirmArchivePresented: Bool {
        if case .confirmArchive = presentation {
            return true
        }
        return false
    }

    private var isConfirmCompletePresented: Bool {
        if case .confirmComplete = presentation {
            return true
        }
        return false
    }
}
