# 📱 UniTrack (iOS, SwiftUI)

UniTrack is a modern **student planner app** built with **SwiftUI** and **MVVM architecture**, using **Firebase Firestore** for real-time cloud storage and **local notifications** for reminders.  
It helps students organize courses, class schedules, assignments, and study sessions, all in one clean interface.

![SwiftUI](https://img.shields.io/badge/SwiftUI-Enabled-blue)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey)

---

## 👩‍💻 Team
**Negar Pirasteh** • **Betty Dang** • **Ngoc Yen Nhi Pham**

---

## 🎯 Project Overview

UniTrack simplifies academic management for students.  
It allows users to:
- Plan and organize their **courses** and **weekly class sessions**  
- Track **assignments** and **exams** with automatic reminders  
- Log **study sessions** with a built-in **Pomodoro timer**  
- View progress in an intuitive **dashboard** synced with the cloud  

All data is stored in **Firebase Firestore** under each user's account and instantly updates across devices.

---

## ✨ Features

### 🗓️ Course & Schedule Management
- Add, edit, or remove **courses** with instructor details and color tags.  
- Add **class sessions** (weekday, start/end time, location).  
- Dashboard view of today's schedule.

### 🧾 Task & Exam Tracking
- Create **assignments** and **exams** linked to courses.  
- Mark tasks as complete or pending.  
- **Automatic reminders** via iOS local notifications.

### ⏱️ Pomodoro Study Timer
- Built-in 25/5 Pomodoro cycle for focused study sessions.  
- Logs every study session as a **StudyLog** with date and duration.

### ☁️ Cloud Sync (Firestore)
- All Courses, Sessions, Tasks, and StudyLogs stored in **Firebase Firestore**.  
- Organized under each user's UID:  
```

users/{uid}/courses/{courseId}
users/{uid}/sessions/{sessionId}
users/{uid}/tasks/{taskId}
users/{uid}/studyLogs/{logId}

```
- Uses **Firebase Authentication** (email or anonymous) to isolate user data.  
- Data syncs automatically when online.

### 🔔 Notifications
- Reminds students of **upcoming due dates** using `UNUserNotificationCenter`.  
- Configurable per task creation or edit.

### 📊 Progress Dashboard
- Shows percentage of completed tasks per course.  
- Displays “Due Soon” tasks and today’s schedule.  
- Optional **Swift Charts** graph of weekly study time.

---

## 🧩 Architecture

**Pattern:** Model–View–ViewModel (MVVM)

```

SwiftUI Views  →  ViewModels  →  Repositories  →  Firebase Firestore
↘──  NotificationService

````

### Main Components
| Layer | Classes | Responsibility |
|-------|----------|----------------|
| **Model** | Course, Session, Task, StudyLog | Data structure & logic |
| **ViewModel** | CourseVM, TaskVM, TimerVM, DashboardVM | Handle app logic, connect models with UI |
| **Service** | NotificationService | Schedule and manage reminders |
| **Repository** | FirestoreRepository | CRUD operations with Firebase Firestore |
| **View** | SwiftUI screens | Display and bind data |

---

## 🗃️ Data Model Summary
| Entity | Attributes | Notes |
|--------|-------------|-------|
| **Course** | id, title, instructor, color | Has many sessions and tasks |
| **Session** | id, courseId, weekday, startTime, endTime, location | Belongs to one course |
| **Task** | id, courseId, type[assignment/exam], title, dueDate, isDone, weight | Belongs to one course |
| **StudyLog** | id, courseId, date, minutes | Created by Pomodoro timer |

---

## 🧱 Tech Stack
- **SwiftUI** — Declarative UI framework  
- **MVVM Architecture** — Clean separation of logic  
- **Firebase Firestore** — Real-time NoSQL cloud database  
- **Firebase Authentication** — Optional sign-in system  
- **UNUserNotificationCenter** — Local notifications  
- **Swift Charts** — Optional analytics graph  

---

## ⚙️ Setup & Installation

### Prerequisites
- Xcode 15 or later  
- iOS 17+ simulator or device  
- Active Firebase project

### Setup Steps
1. Clone this repo:
   ```bash
   git clone https://github.com/<your-user>/UniTrack.git

2. Open `UniTrack.xcodeproj` in Xcode.
3. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
4. Enable **Firestore Database** and **Authentication (Email/Password or Anonymous)**.
5. Download your `GoogleService-Info.plist` file and drag it into the Xcode project (do not commit it to GitHub).
6. Add Firebase via Swift Package Manager:

   ```
   https://github.com/firebase/firebase-ios-sdk
   ```

   Include **FirebaseAuth** and **FirebaseFirestore**.
7. Build and run on a simulator or device.

---

## 🧮 Firestore Structure

```
users
 └── {uid}
      ├── courses
      │    └── {courseId}
      ├── sessions
      │    └── {sessionId}
      ├── tasks
      │    └── {taskId}
      └── studyLogs
           └── {logId}
```

Each user’s data is isolated and secured via Firestore security rules.

---

## 🔒 Firestore Security Rules (Sample)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧩 Milestones (Course Schedule)

### **📌 Phase 1 – Completed (First 50%)**

The first half of the project focused on building the full foundation of UniTrack:

#### **Authentication + Role-Based Navigation**

* Firebase Authentication (email or anonymous)
* Automatic routing to **Student** or **Teacher** dashboard
* Profile page showing user info and allowing sign-out

#### **New Dashboard (Student + Teacher)**

* Fully redesigned dashboard with four main entry points:

  * **Courses**
  * **Assignments**
  * **Focus Timer**
  * **Profile**
* Cleaner UI, unified for both roles

#### **Course Module (CRUD)**

* Add, edit, delete courses
* Course list with improved UI
* Course detail screen with:

  * Sessions list + “Add Session”
  * Tasks list + “Add Task”

#### **Task / Assignment Management**

* Add tasks (assignment/exam)
* Link tasks to a course
* Mark tasks done / undone
* Global Assignments view accessible from Dashboard
* Every task stored under the correct course ID

#### **Focus Timer**

* Basic study timer built with SwiftUI
* Ready for Phase 2 integration with StudyLog

#### **Firestore Integration**

* Repositories for courses, tasks, sessions
* Live listeners that automatically update UI
* MVVM architecture finalised

**Phase 1 was delivered successfully.**

---

### **📌 Phase 2 – Remaining (Final 50%)**

Phase 2 focuses on completing and polishing the full UniTrack experience:

#### **Teacher Tools**

* Manage course content more easily
* (Optional) Analytics for student progress

#### **Student UX Improvements**

* “Today’s Tasks” section
* Upcoming deadlines widget
* Course cards with progress indicators

#### **Focus Timer + Study Logs**

* Save Pomodoro sessions in Firestore
* Study history page

#### **UI/UX Polish**

* Color theme improvements
* Uniform headers and cards
* Small animations and nicer icons

#### **Quality & Performance**

* Error handling
* Loading indicators
* Cleanup of unused code
* Testing

#### **Final Deliverables**

* Screenshots
* README polish
* PDF submission
* Demo video preparation

---

### **Milestone Table (Course Schedule)**

| Week            | Deliverable                           | Progress              |
| --------------- | ------------------------------------- | --------------------- |
| **Week 8**      | Proposal + UML diagrams + repo setup  | ✅ Completed           |
| **Weeks 9–10**  | Firestore setup + Course/Session CRUD | ✅ Completed (Phase 1) |
| **Weeks 11–12** | Task CRUD + timer foundation          | ✅ Completed (Phase 1) |
| **Week 13**     | Dashboard redesign + full navigation  | ✅ Completed (Phase 1) |
| **Week 14**     | Phase 2 UX improvements + StudyLog    | 🔜 In Progress        |
| **Week 15**     | Final polish + README + demo          | 📦 Pending            |


---

## 🧪 Testing

Basic tests on ViewModels:

* Task creation & completion
* Firestore read/write
* Notification scheduling logic

---

## 📸 UML Diagrams

All diagrams are inside `/Docs/UML/`:

* Class Diagram
* Flowchart (Add Task)
* Activity Diagram (Notification)
* ER Diagram (Firestore structure)

---

## 🤝 Collaboration

### Branching

* `main` – stable version
* `feature/firebase` – Firestore integration
* `feature/tasks` – CRUD logic
* `feature/timer` – Pomodoro
* `ui/polish` – design refinement

Each teammate works in their feature branch → Pull Request → Review → Merge into `main`.

### Commit Style

Use simple, clear messages:

```
feat(tasks): add Firestore write
fix(timer): correct countdown display
docs: add class diagram to docs
```

---

## 🧭 Demo Plan (for presentation)

1. 1 min – Intro (goal + features)
2. 2 min – Show creating Course & Session
3. 1.5 min – Add Task → automatic reminder
4. 1.5 min – Run Pomodoro timer + progress view
5. 0.5 min – Firestore real-time sync and conclusion

---

## 📄 License

This project is released under the **MIT License** — free to use and modify.

---

## 🧠 Future Enhancements

* Multi-user sync (teachers / group projects)
* Dark mode and custom themes
* Widgets for “Today’s Tasks”
* iCloud backup and export

---

### ✨ Summary

**UniTrack** brings together scheduling, task tracking, and study logging into one intuitive iOS experience — powered by SwiftUI and Firebase.
It demonstrates strong architecture, teamwork, and cloud integration suitable for academic and real-world use.


