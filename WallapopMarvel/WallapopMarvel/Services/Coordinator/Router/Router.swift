//
//  Router.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import UIKit

protocol RouterType: AnyObject, Presentable {
    var navigationController: UINavigationController { get }
    var rootViewController: UIViewController? { get }
    /// Presents  module modally
    func present(_ module: Presentable, animated: Bool)
    /// Dismisses modal module
    func dismissModule(animated: Bool, completion: (() -> Void)?)
    /// Pushes module or vc into the navigationController stack
    func push(_ module: Presentable, animated: Bool, completion: (() -> Void)?)
    /// Pops the last controller or module in the navigationController stack
    func popModule(animated: Bool)
    /// Pops all controllers managed by coodrinator
    func popModule(for coordinator: Coordinator<DeepLink>, animated: Bool)
    /// Sets the root controller in navigationController
    func setRootModule(_ module: Presentable, hideBar: Bool, animated: Bool)
    /// Pops rootViewController
    func popToRootModule(animated: Bool)
}

final class Router: NSObject, RouterType, UINavigationControllerDelegate {
    /// Stores all completionHandlers for controllers
    private var completions: [UIViewController: () -> Void]
    var hasRootController: Bool { rootViewController != nil }
    let navigationController: UINavigationController
    var rootViewController: UIViewController? { navigationController.viewControllers.first }

    init(navigationController: UINavigationController = BaseNavigationController()) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        self.navigationController.delegate = self
    }

    func present(_ module: Presentable, animated: Bool = true) {
        navigationController.present(module.toPresentable(), animated: animated, completion: nil)
    }

    func dismissModule(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    func push(_ module: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {
        let controller = module.toPresentable()
        // Avoid pushing UINavigationController onto stack
        guard controller is UINavigationController == false else { return }
        if let completion = completion {
            completions[controller] = completion
        }
        navigationController.pushViewController(controller, animated: animated)
    }

    func popModule(animated: Bool = true) {
        guard let controller = navigationController.popViewController(animated: animated) else { return }
        runCompletion(for: controller)
    }

    func setRootModule(_ module: Presentable, hideBar: Bool = false, animated: Bool = false) {
        // Call all completions so all coordinators can be deallocated
        completions.forEach { $0.value() }
        navigationController.setViewControllers([module.toPresentable()], animated: animated)
        navigationController.isNavigationBarHidden = hideBar
    }

    func popToRootModule(animated: Bool) {
        guard let controllers = navigationController.popToRootViewController(animated: animated) else { return }
        controllers.forEach { runCompletion(for: $0) }
    }

    func popModule(for coordinator: Coordinator<DeepLink>, animated: Bool) {
        let flowFirstVC = coordinator.toPresentable()
        guard flowFirstVC is UINavigationController == false else { return }
        var controllers = navigationController.viewControllers
        guard let indexOfTheFirstVCInFlow = controllers.firstIndex(where: { $0 == flowFirstVC }) else { return }
        let vcsToRemove = Array(controllers.suffix(from: indexOfTheFirstVCInFlow))
        controllers.removeLast(vcsToRemove.count)
        navigationController.setViewControllers(controllers, animated: animated)
        vcsToRemove.forEach { runCompletion(for: $0) }
    }

    fileprivate func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }

    // MARK: Presentable

    func toPresentable() -> UIViewController { navigationController }

    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        // Ensure the view controller is popping
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(poppedViewController) else {
            return
        }
        runCompletion(for: poppedViewController)
    }
}
