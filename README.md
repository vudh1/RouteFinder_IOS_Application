# RouteFinder — Activity-Aware iOS Place Recommendations

RouteFinder is an iOS app that turns a user's activity goal into a nearby place recommendation.

It combines **HealthKit activity data, live location, Google Places/Directions data, and preference-based ranking** to suggest destinations that fit how far the user wants to walk.

## Demo

![RouteFinder demo](app_ui.gif)

## Core features

- reads steps, walking/running distance, height, and weight from HealthKit;
- lets the user set an activity/distance goal;
- searches nearby places by selected categories;
- retrieves walking distance and travel time for each destination;
- ranks destinations by:
  - closeness to the user's target distance;
  - distance from the current location; or
  - learned preference score;
- remembers liked categories and previously explored places;
- displays destinations in a list and on a map;
- keeps lightweight location/history state with `UserDefaults`.

## Recommendation flow

```text
HealthKit + user goal
        |
        v
Desired walking distance
        |
        v
Current GPS location
        |
        v
Google Places nearby search
        |
        v
Google Directions walking distance
        |
        v
Preference + distance ranking
        |
        v
Recommended destinations / map
```

The ranking implementation uses binary-search-assisted insertion to order candidate destinations by distance-to-goal or preference score.

## Tech stack

- Swift / UIKit
- HealthKit
- CoreLocation
- Google Places API
- Google Directions API
- Alamofire
- SwiftyJSON
- CocoaPods

## Project structure

| File | Responsibility |
| --- | --- |
| `HealthDataController.swift` | HealthKit data, activity goal, and preference state |
| `NavigationController.swift` | location lookup, Places/Direction requests, and result presentation |
| `LocationDirectionModel.swift` | destination model and ranking/sorting algorithms |
| `MapController.swift` | map presentation |
| `LocationHistoryController.swift` | previously viewed destination history |
| `SetLocationTypeController.swift` | preferred place categories |
| `SetDistanceController.swift` | target-distance input |

## Running the app

### Requirements

- macOS with Xcode
- CocoaPods
- an iOS device/simulator supported by the Xcode project
- a Google Maps Platform API key with the required Places and Directions access
- HealthKit capability enabled for the app target

### 1. Install dependencies

```bash
cd RouteFinder-Application
pod install
```

Open:

```text
RouteFinder-Application.xcworkspace
```

### 2. Configure Google APIs

A safe template is included at:

```text
RouteFinder-Application/RouteFinder-Application/Keys.example.plist
```

Copy it to `Keys.plist`, replace the placeholder key, and make sure the file is included in the application target.

`Keys.plist` is ignored by Git so credentials are not committed.

### 3. Build and run

Select the `RouteFinder-Application` scheme in Xcode and run it. Grant location and Health permissions when prompted.

## Notes

This is a 2020 academic iOS project. External API behavior, CocoaPods versions, and Xcode migration requirements can change over time, but the repository remains a useful example of combining **mobile sensors, external APIs, personalization, and ranking logic** in one application.
