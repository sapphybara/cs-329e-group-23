# cs-329e-group-23

### Name Of Project: PDEffIt
Team Members: Max Kretschmer, Warren Wiser, Santiago Leyva, Corey Zhang
Dependencies: Xcode 14, Swift 5

Special Instructions:
- Prioritize running the application on a physical phone (in portrait mode) to have camera access, if not possible use iPhone 13 Pro Max (in portrait mode) when building with simulator.
- Don't forget to swipe between VC's, Gesture Recongition is implemented here.
- Can create own account or use our test account, username: g<span>@</span>g.com password: beansbeans

Required feature checklist:
- [x] Login/register path with Firebase.  
  - Change Username
  - Change Password
  - Change Profile Pic
- [x] <a id="settings-options"></a>Settings screen. The three behaviors we implemented are:  
  - Change Dark Mode
  - Change Haptic
  - Change Font
- [x] Non-default fonts and colors used  

Two major elements used:
- [ ] Core Data
- [x] User Profile path using camera and photo library
- [x] Multithreading
- [ ] SwiftUI  

Minor Elements used:
- [x] Two additional view types such as sliders, segmented controllers, etc. The two we
implemented are:
  - Segmented controllers
  - UIPickerController
  - ProgressView

One of the following:
- [ ] Table View
- [x] Collection View
- [x] Tab VC
- [ ] Page VC

Two of the following:
- [x] Alerts
- [ ] Popovers
- [x] Stack Views
- [x] Scroll Views
- [x] Haptics
- [ ] User Defaults

At least one of the following per team member:
- [x] Local notifications
- [ ] Core Graphics
- [x] Gesture Recognition
- [x] Animation
- [ ] Calendar
- [ ] Core Motion
- [ ] Core Location / MapKit
- [ ] Core Audio
- [x] Others (such as QR code, Koloda, etc.) with approval from the instructor – list them
  - [x] Firebase Storage - For Retrieving, Syncing, Uploading, and Deleting All Created User Data

Work Distribution Table:  
| Required Feature | Description                 | Who / Percentage worked on  |
| ---------------- |-----------------------------| ------|
| Major Element: User Profile path using camera and photo library  | Allows user to change the profile image and sends it to a server save location | Warren 60%, Santiago 40% |
| Major Element: Multithreading  | Allows multithreading for PDF display and it's thumbnails, for file deletion between local and server user uploaded files, maintains security over user-uploaded files, data retrieval implementation as well. | Warren 40%, Santiago 60% |
| Minor Element: Segmented Controller  | Login/Signup Implementation | Warren 100% |
| Minor Element: UIPickerController | Implementation within settings for user selected custom font. | Warren 100% |
| Minor Element: ProgressView | Used for the animation for the loadscreen when launching the application. | Max 100% |
| Minor Element: Collection View | Used for the display of all user-made PDF files (as thumbnails). | Corey 100% |
| Minor Element: Alerts | Used when alerting a user that is deleting a file, used for when clicks on the help button, also implemented user settings and profile VC (if email is invalid and re-authentiction)  | Warren 60%, Santiago 20%, Corey 20% |
| Minor Element: Stack Views | Used in profile page, when logged in, and when logged out. | Warren 100% |
| Minor Element: Scroll Views | Used when you click on a PDF thumnnail and view it in PDFView | Corey 100% |
| Minor Element: Scroll Views | Used in the profile settings, a switch was implemented to allow the user to get haptic/vibrational feedback from the application. | Corey 60%, Warren 40% |
| Minor Element: Local Notification | Used to inform the user that their newly scanned PDFs are available when the user navigates out of the application after scanning/or uploading a new PDF file. | Max 99%, Santiago 1% |
| Minor Element: Gesture Recognition | Used to allow swipe navigation to the different pages within the application. | Corey 100% |
| Minor Element: Animation | Used to animate the progress of the Progress View when the application launches. | Max 100% |
| Minor Element: Firebase Storage     | Allows for the retrieval, upload (uniquely made and checked files), sycncing, and deleting of all user made data to a save location unique only to the user that is logged in. It also stores user profile images in a user save location separate from all user made files.  | Santiago 90%, Warren 10% |
| User Profile Route | A page to control authorization and user details | Warren 100% |
| Login Screen | On the profile page; allows users to both log in and create an account | Warren 96%, Santiago 4% |
| Settings Screen | Allows users to change the settings of the app from the profile page, as described [here](#settings-options).      | Warren 100% |
| UI Design     | Overall design and aesthetic of the app, along with dark mode | Warren 100% |
| File Deletion, it's UI, and Alert     | Allows users to delete data (both locally and on the server, depending on user login status) | Santiago 98%, Warren 2% |
| Display PDF file in PDFview from cell     | Allows user to navigate the file in PDFview, and displays the file name. | Corey 95%, Santiago 5% |
| Home View Controller Display     | Allows user see all available PDF files in a collection view and updates the the welcome message based on the logged-in status of the user, syncs data if user is logged in from the launch of the application. | Corey 80%, Santiago 10%, Warren 10% |
| Retrieving images from camera and photo roll, and automatic page scanning and detection, and related VCs | Allows user to automatically detect a page with their camera, and allows for the image(s) to have a filter as well, and allows the user to upload an image from their camera view to be converted into a PDF file.      | Max 100% |
| File data management within application | Management of user-made data for the entire application (data structure setup, PDF conversions, and conversion of bytes from server to local application data to a usable format) for front end and UI side.     | Santiago 100% |

### Referenced Media
- Default profile image: <a target="_blank" href="https://icons8.com/icon/23264/user">User</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
- Scanner image: [Scanner](https://thenounproject.com/icon/scanner-1036158/) by Creative Mania on the [Noun Project](https://thenounproject.com/)
- Color Pallete: derived from [BlueprintJS](https://blueprintjs.com/docs/#blueprint), a UI toolkit for developing web applications with React. Entire pallete [here](https://github.com/palantir/blueprint/blob/develop/packages/colors/src/_colors.scss).
