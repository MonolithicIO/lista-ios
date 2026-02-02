//
//  InstanceKeeper.swift
//  lista
//
//  Created by Lucca Beurmann on 15/01/26.
//

import Combine
import CoreData
import SwiftUI

@Observable
class InstanceKeeper {

    // MARK: - Initializers
    private init() {}

    static let shared: InstanceKeeper = .init()

    // MARK: - Singletons
    private var listDatasource: ListDataSourceProtocol?
    private var listRepository: ListRepositoryProtocol?
    private var listItemDatasource: ListItemDataSourceProtocol?
    private var listItemRepository: ListItemRepositoryProtocol?

    // MARK: - Core
    func provideDateProvider() -> DateProviderProtocol {
        return DateProvider()
    }
    
    func provideUuidProvider() -> UUIDProviderProtocol {
        return UUIDProvider()
    }
    
    func provideDiskManager() -> DiskManagerProtocol {
        return DiskManager()
    }

    // MARK: - Data Providers
    func provideContext() -> NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }

    func provideListDatasource() -> ListDataSourceProtocol {
        guard let dataSource = listDatasource else {
            listDatasource = ListDataSource(
                context: provideContext(),
                dateProvider: provideDateProvider()
            )
            return listDatasource!
        }
        return dataSource
    }

    func provideListRepository() -> ListRepositoryProtocol {
        guard let repository = listRepository else {
            listRepository = ListRepository(datasource: provideListDatasource())
            return listRepository!
        }
        return repository
    }

    func provideListItemDatasource() -> ListItemDataSourceProtocol {
        guard let dataSource = listItemDatasource else {
            let newInstance = ListItemDataSource(
                context: provideContext(),
                dateProvider: provideDateProvider(),
                diskManager: provideDiskManager(),
                uuidProvider: provideUuidProvider()
                
            )
            self.listItemDatasource = newInstance

            return newInstance
        }

        return dataSource
    }

    func provideListItemRepository() -> ListItemRepositoryProtocol {
        guard let listRepository = self.listItemRepository else {
            let newInstance = ListItemRepository(
                datasource: provideListItemDatasource()
            )
            self.listItemRepository = newInstance

            return newInstance
        }

        return listRepository
    }

    // MARK: - Domain Providers
    func provideCreateListService() -> CreateListServiceProtocol {
        return CreateListService(repository: provideListRepository())
    }

    func provideFetchListsService() -> FetchListsServiceProtocol {
        return FetchListsService(repository: provideListRepository())
    }

    func provideRemoveListService() -> RemoveListServiceProtocol {
        return RemoveListService(repository: provideListRepository())
    }

    func provideFetchListDetailsService() -> FetchListaDetailsServiceProtocol {
        return FetchListaDetailsService(repository: provideListRepository())
    }

    func provideCreateListItemService() -> CreateListItemServiceProtocol {
        return CreateListItemService(
            listItemRepository: provideListItemRepository()
        )
    }

    func provideUpdateItemStatusService() -> UpdateItemStatusServiceProtocol {
        return UpdateItemStatusService(
            repository: provideListItemRepository()
        )
    }
    
    func provideArchiveListService() -> ArchiveListServiceProtocol {
        return ArchiveListService(repository: provideListRepository())
    }

    func provideCompleteListService() -> CompleteListServiceProtocol {
        return CompleteListService(repository: provideListRepository())
    }

    func provideRevertCompleteService() -> RevertCompleteServiceProtocol {
        return RevertCompleteService(repository: provideListRepository())
    }

    // MARK: - Presentation Providers
    func provideHomeViewModel() -> HomeScreen.ViewModel {
        return HomeScreen.ViewModel(
            fetchListsService: provideFetchListsService(),
            createListService: provideCreateListService(),
            removeListService: provideRemoveListService()
        )
    }

    func provideDetailsViewModel() -> DetailsViewModel {
        return DetailsViewModel(
            fetchDetailsService: provideFetchListDetailsService(),
            createItemService: provideCreateListItemService(),
            updateItemStatusService: provideUpdateItemStatusService(),
            deleteListService: provideRemoveListService(),
            archiveListService: provideArchiveListService(),
            dateProvider: provideDateProvider(),
            completeListService: provideCompleteListService(),
            revertCompleteListService: provideRevertCompleteService()
        )
    }
}

