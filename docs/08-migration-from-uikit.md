# Migrating from Plain UIKit

This guide is for developers who are already comfortable with UIKit and want to adopt UIKitDSL incrementally in an existing codebase.

---

## Why migrate?

| Pain point in plain UIKit | UIKitDSL solution |
|---|---|
| `viewDidLoad` fills with `addSubview` / `NSLayoutConstraint.activate` boilerplate | Declarative `@ViewBuilder` body that composes components |
| Scattered state: `IBOutlet` + manual `updateUI()` calls | Typed `State` struct + automatic reconciliation |
| Navigation logic spread across view controllers | `Coordinator` protocol with `add(child:)` / `remove(child:)` |
| Gesture targets — `#selector`, `@objc` methods, weak/strong dance | `.gesture(.pan { ... })` or `.onTap { ... }` closures |
| Reuse in table/collection cells — `prepareForReuse`, partial updates | `update(_:)` called by the reconciler; `BoundComponent` for partials |

---

## Before / after: a typical view controller

### Before (plain UIKit)

```swift
final class ProfileViewController: UIViewController {

    // MARK: - Model
    var user: User? { didSet { updateUI() } }

    // MARK: - Views
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let editButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
        updateUI()
    }

    // MARK: - Setup

    private func setupViews() {
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 40
        avatarView.layer.masksToBounds = true
        view.addSubview(avatarView)

        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        view.addSubview(nameLabel)

        emailLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        emailLabel.textColor = .secondaryLabel
        view.addSubview(emailLabel)

        editButton.setTitle("Edit Profile", for: .normal)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        view.addSubview(editButton)
    }

    private func setupConstraints() {
        [avatarView, nameLabel, emailLabel, editButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            avatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),

            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24)
        ])
    }

    // MARK: - Updates

    private func updateUI() {
        guard isViewLoaded, let user = user else { return }
        avatarView.image = UIImage(systemName: user.avatarSystemName)
        nameLabel.text = user.name
        emailLabel.text = user.email
    }

    @objc private func editTapped() {
        // push edit screen
    }
}
```

### After (UIKitDSL)

```swift
final class ProfileViewModel: ObservableViewModel<ProfileViewModel.State> {
    struct State {
        var user: User
    }
    init(user: User) { super.init(initialState: State(user: user)) }
}

final class ProfileScreen: DSLViewController<ProfileViewModel> {
    init(viewModel: ProfileViewModel, coordinator: ProfileCoordinator) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 16, alignment: .center) {
                image(systemName: state.user.avatarSystemName)
                    .frame(width: 80, height: 80)
                    .contentMode(.scaleAspectFill)
                    .cornerRadius(40)
                label(state.user.name)
                    .font(.title1)
                label(state.user.email)
                    .font(.subheadline)
                    .tintColor(.secondaryLabel)
                button("Edit Profile") {
                    coordinator.showEditProfile()
                }
            }
            .padding(32)
        }
    }
}
```

**What changed:**
- Zero `addSubview` or `NSLayoutConstraint` calls — layout comes from `vstack` and modifiers.
- No `updateUI()` method — the reconciler calls `update(_:)` on changed components automatically.
- No `@objc` selector — the button closure captures `coordinator` directly.

---

## Before / after: a table view item renderer

### Before (plain UIKit cell)

```swift
final class ItemCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let badgeView = UIView()
    private let badgeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 40+ lines of setupViews + setupConstraints
    }

    func configure(with item: Item) {
        titleLabel.text = item.title
        badgeView.isHidden = !item.isNew
        badgeLabel.text = "NEW"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        badgeView.isHidden = true
    }
}
```

### After (UIKitDSL via ContainerComponent)

```swift
// No UITableViewCell subclass needed for simple rows.
// Build the row component inline in cellForRowAt:

func tableView(_ tableView: UITableView,
               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let item = items[indexPath.row]

    let row = hstack(spacing: 8, alignment: .center) {
        label(item.title)
        spacer()
        if item.isNew {
            label("NEW")
                .font(.caption1)
                .background(.systemBlue)
                .cornerRadius(4)
                .tintColor(.white)
                .padding(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        }
    }
    .padding(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))

    let reconciler = Reconciler()
    reconciler.reconcile([row], in: cell.contentView)
    return cell
}
```

For high-performance lists with many cells, store a `Reconciler` per cell and call `reconcile` on reuse — the reconciler updates only what changed.

---

## Tips for mixed codebases

### Adopt one screen at a time

`DSLViewController` is a `UIViewController` subclass. You can push it from any existing `UINavigationController` and it participates in all standard navigation patterns.

```swift
// From a legacy UIViewController:
let vm = SettingsViewModel()
let settings = SettingsScreen(viewModel: vm)
navigationController?.pushViewController(settings, animated: true)
```

### Keep your existing Storyboard screens

You don't have to migrate everything at once. Leave Storyboard screens as-is and introduce UIKitDSL only in new screens or during refactors.

### Use container for existing custom views

If you have a heavily customised `UIView` subclass you're not ready to convert, wrap it in `container`:

```swift
container(
    build: { MyLegacyChart() },
    update: { view in
        (view as? MyLegacyChart)?.data = state.chartData
    }
)
.frame(height: 200)
```

### Migrate view model logic first

The `ObservableViewModel` pattern works with any `UIViewController`. Move state into a view model and wire `onStateChange` before converting the layout to DSL — this breaks the migration into two independent steps.

```swift
// Step 1: view model only, no DSL yet
class LegacyViewController: UIViewController {
    let viewModel = MyViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onStateChange = { [weak self] _ in self?.updateUI() }
    }
}

// Step 2: replace setupViews + updateUI with DSLViewController body
```

### Use coordinators to untangle navigation

Before touching any layout, extract `pushViewController` / `present` calls from your view controllers into a `Coordinator`. This decouples navigation from presentation and is the most impactful refactor you can make independent of the DSL.
