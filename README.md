# cs-329e-group-23

Name Of Project: PDEffIt  
Team Members: Max Kretschmer, Warren Wiser, Santiago Leyva, Corey Zhang  
Dependencies: Xcode 14, Swift 4  

Special Instructions:
- Use iPhone 13 Pro Max when building with simulator, or run on phone to have camera access
- Can create own account or use our test account, username: g@g.com password: beansbeans

Required feature checklist:
- [x] Login/register path with Firebase.  
- [x] “Settings” screen. The three behaviors we implemented are:  
  - Change Username
  - Change Password
  - Change Profile Pic
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
  - Scroll View

One of the following:
- [ ] Table View
- [x] Collection View
- [ ] Tab VC
- [ ] Page VC

Two of the following:
- [x] Alerts
- [ ] Popovers
- [ ] Stack Views
- [x] Scroll Views
- [x] Haptics
- [ ] User Defaults

At least one of the following per team member:
- [x] Local notifications
- [ ] Core Graphics
- [x] Gesture Recognition
- [ ] Animation
- [ ] Calendar
- [ ] Core Motion
- [ ] Core Location / MapKit
- [ ] Core Audio
- [ ] Others (such as QR code, Koloda, etc.) with approval from the instructor – list them
- [x] Firebase Storage - For Retrieving, Syncing, Uploading, and Deleting All Created User Data

Work Distribution Table:  
| Required Feature | Description                 | Who / Percentage worked on  |
| ---------------- |-----------------------------| ------|
| log in screen     | Allows users to both log in and create an account | Warren 96%, Santiago 4% |
| UI Design     | Overall design and aesthetic of the app, along with darkmode      | Warren 100% |
| Settings | Allows users to change the settings of the app including profile settings and visual settings      | Warren 100% |
| Firebase Storage     | Allows for the retrieval, upload (uniquely made and checked files), sycncing, and deleting of all user made data to a save location unique only to the user that is logged in. It also stores user profile images in a user save location separate from all user made files.  | Santiago 90%, Warren 10% |
| File Deletion, it's UI, and Alert     | Allows users to delete data (both locally and on the server, depending on user login status) | Santiago 98%, Warren 2% |
| Display PDF file in PDFview from cell     | Allows user to navigate the file in PDFview, and displays the file name. | Corey 95%, Santiago 5% |
| Home View Controller Display     | Allows user see all available PDF files in a collection view and updates the the welcome message based on the logged-in status of the user, syncs data if user is logged in from the launch of the application. | Corey 80%, Santiago 10%, Warren 10% |



### References
- Profile image: <a target="_blank" href="https://icons8.com/icon/23264/user">User</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
- Scanner image: [Scanner](https://thenounproject.com/icon/scanner-1036158/) by Creative Mania on the [Noun Project](https://thenounproject.com/)
- Color Pallete: derived from [BlueprintJS](https://blueprintjs.com/docs/#blueprint), a UI toolkit for developing web applications with React. Entire pallete [here](https://github.com/palantir/blueprint/blob/develop/packages/colors/src/_colors.scss).
