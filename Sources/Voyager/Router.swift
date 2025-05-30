import Foundation

public class Router<T: Route>: ObservableObject {
    // MARK: -
    
    @Published public var root: T
    @Published public var routes: [T]
    @Published var sheet: T?
    @Published var fullscreenCover: T?
    @Published var popover: T?
    
    var onDismiss: (() -> Void)?
    var deeplinkHandler: DeeplinkHandler<T>?
    
    // MARK: - Initializer

    public convenience init(root: @escaping () -> T, deeplinkHandler: DeeplinkHandler<T>? = nil) {
        self.init(root: root(), deeplinkHandler: deeplinkHandler)
    }
    
    public init(root: T, deeplinkHandler: DeeplinkHandler<T>? = nil) {
        self.root = root
        self.routes = []
        self.deeplinkHandler = deeplinkHandler
    }
    
    // MARK: -
    
    public func updateRoot(_ route: T) {
        root = route
        routes.removeAll()
    }
    
    public func present(_ route: T, option: PresentationOption = .navigation, onDismiss: (() -> Void)? = nil) {
        switch option {
        case .fullscreenCover:
            presentFullscreenCover(route, onDismiss: onDismiss)
        case .popover:
            presentPopover(route)
        case .navigation:
            push(route)
        case .sheet:
            presentSheet(route, onDismiss: onDismiss)
        }
    }
    
    public func dismiss(_ option: PresentationOption? = nil) {
        switch option {
        case .fullscreenCover:
            fullscreenCover = nil
        case .navigation:
            pop()
        case .popover:
            popover = nil
        case .sheet:
            sheet = nil
        case .none:
            if sheet != nil {
                sheet = nil
            } else if fullscreenCover != nil {
                fullscreenCover = nil
            } else if popover != nil {
                popover = nil
            } else {
                pop()
            }
        }
    }
    
    public func handleDeeplink(url: URL) {
        if let (route, option) = deeplinkHandler?.handleDeeplink(url: url) {
            present(route, option: option)
        }
    }
    
    // MARK: - Private
    
    private func push(_ route: T) {
        routes.append(route)
    }
    
    private func pop() {
        routes.removeLast()
    }
    
    private func presentSheet(_ route: T, onDismiss: (() -> Void)? = nil) {
        sheet = route
        self.onDismiss = onDismiss
    }
    
    private func presentFullscreenCover(_ route: T, onDismiss: (() -> Void)? = nil) {
        fullscreenCover = route
        self.onDismiss = onDismiss
    }
    
    private func presentPopover(_ route: T) {
        popover = route
    }
}
