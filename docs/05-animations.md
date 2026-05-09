# Animations

UIKitDSL's animation system is built on `UIViewPropertyAnimator`, which gives you interruptible, scrubbable, velocity-aware animations with a declarative API.

---

## DSLAnimation presets

`DSLAnimation` packages a duration, a timing curve, and an optional delay. Four presets cover most cases:

| Preset | Duration | Curve | Best for |
|---|---|---|---|
| `.smooth` | 0.35 s | easeInOut | Content changes, layout shifts |
| `.snappy` | 0.2 s | easeOut | Dismissals, quick feedback |
| `.bouncy` | 0.5 s | spring (0.6 damping) | Cards, sheets, toggles |
| `.spring(damping:response:)` | response | spring | Custom physics feel |

```swift
// Choose a preset
let animation: DSLAnimation = .bouncy

// Or customise
let animation = DSLAnimation(duration: 0.4, curve: .easeOut)
let springAnim = DSLAnimation.spring(damping: 0.5, response: 0.6)
```

---

## AnimationCoordinator.animate()

`AnimationCoordinator` is a lightweight wrapper around `UIViewPropertyAnimator` that tracks running animators by a stable `AnyHashable` id so it can interrupt and restart them on each state change.

### Basic usage

```swift
let animCoord = AnimationCoordinator()

// Somewhere in your view controller:
animCoord.animate(
    view: circleView,
    id: "circle-position",
    animation: .bouncy
) {
    circleView.transform = CGAffineTransform(translationX: 0, y: -120)
}
```

### With velocity (gesture hand-off)

Pass an initial velocity vector derived from a pan gesture's velocity so the animation feels physically continuous:

```swift
let velocity = panRecognizer.velocity(in: view)
let vector = CGVector(
    dx: velocity.x / distanceRemaining.x,
    dy: velocity.y / distanceRemaining.y
)

animCoord.animate(
    view: cardView,
    id: "card-snap",
    animation: .spring(damping: 0.7, response: 0.4),
    initialVelocity: vector
) {
    cardView.transform = .identity
}
```

### Interruptible animations

If `animate(view:id:animation:changes:)` is called while an animation with the same `id` is running, the coordinator stops the in-flight animator at its current position before starting a new one — preventing jarring jumps:

```swift
// Called rapidly on each state change — safe to call mid-flight.
animCoord.animate(view: thumb, id: "toggle-thumb", animation: .snappy) {
    thumb.transform = isOn
        ? CGAffineTransform(translationX: trackWidth - thumbDiameter, y: 0)
        : .identity
}
```

---

## DSLTransition

`DSLTransition` defines how a view enters and leaves the screen. The reconciler applies it when a component is inserted into or removed from the live view tree.

### Presets

```swift
// Fade
let t: DSLTransition = .opacity

// Scale + fade
let t: DSLTransition = .scale

// Slide from an edge
let t: DSLTransition = .slide(.bottom)
let t: DSLTransition = .slide(.trailing)

// Combine multiple transitions
let t: DSLTransition = .combined(.opacity, .scale)
```

### Custom transition

Provide three closures: `onInsert` sets the start state, `onInsertCompletion` animates to the rest state, and `onRemove` runs the exit animation and calls its completion when done.

```swift
let flip = DSLTransition(
    onInsert: { view in
        view.layer.transform = CATransform3DMakeRotation(.pi / 2, 0, 1, 0)
        view.alpha = 0
    },
    onInsertCompletion: { view in
        view.layer.transform = CATransform3DIdentity
        view.alpha = 1
    },
    onRemove: { view, completion in
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: []) {
            view.layer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 1, 0)
            view.alpha = 0
        } completion: { _ in completion() }
    }
)
```

---

## Gesture velocity hand-off

The `GestureBridge.pan` case exposes a `PanGestureInfo` struct containing the current translation and velocity. On `.ended`, read the velocity and pass it to `AnimationCoordinator` so the snap-back animation starts at the same speed the user's finger was moving:

```swift
// In your DSLViewController body closure:
container(build: { circleView }, update: { _ in })
    .gesture(.pan { info in
        switch info.state {
        case .changed:
            viewModel.mutate { $0.dragOffset = info.translation }
            circleView.transform = CGAffineTransform(
                translationX: info.translation.x,
                y: info.translation.y
            )

        case .ended:
            viewModel.mutate { $0.dragOffset = .zero }
            let vel = info.velocity
            let vector = CGVector(dx: vel.x / 200, dy: vel.y / 200)
            animCoord.animate(
                view: circleView,
                id: "circle-snap",
                animation: .spring(damping: 0.7, response: 0.45),
                initialVelocity: vector
            ) {
                circleView.transform = .identity
            }

        default: break
        }
    })
```

---

## Matched geometry transitions

`MatchedGeometryNamespace` lets two views in different parts of the hierarchy (or even in different view controllers) animate between each other's frames.

```swift
// Shared namespace — create once and pass to both screens.
let namespace = MatchedGeometryNamespace()

// Source screen: tag the thumbnail.
image(named: item.imageName)
    .matchedGeometry(id: item.id, in: namespace)
    .frame(width: 60, height: 60)

// Detail screen: tag the hero image with the same id.
image(named: item.imageName)
    .matchedGeometry(id: item.id, in: namespace)
    .frame(height: 300)
    .contentMode(.scaleAspectFill)
```

The `DSLTransitionAnimator` reads the source frame from `namespace.registry[id]` and animates the destination view from that frame to its natural position during a custom `UIViewControllerAnimatedTransitioning` transition.
