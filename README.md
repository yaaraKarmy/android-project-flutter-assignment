Dry part answers:
1. The class that is used to implement the controller pattern in this library is: SnappingSheetController.
The features it allows the developer to control are: the position of the snapping sheet - snap to position X or use snappingPosition to do so with animation,
stop ongoing snapping, get the current position and the state of the snapping sheet - rather it's attached, in the move or not.

2. The parameter that controls this behavior is: SnappingPositions.

3. Advantage of inkWell over GestureDetector: inkwell has an effect of ink splash when tapped (ripple effect), GestureDetector doesn't have it.
Advantage of GestureDetector over inkWell: GestureDetector provides more control over the touchable widget -
 gives you more option to detect user interaction and have custom gestures that applies to those interactions, like: dragging.
