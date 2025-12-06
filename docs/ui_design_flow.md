This updated requirement heavily shifts the design to a **Calendar-first approach** and necessitates a clear definition of the **Home Screen** and the **Navigation Flow**.

I will update the UI Design Flow based on the provided image style, prioritizing accessibility (high contrast, large targets) while integrating the requested calendar structure and new navigation tabs.

## **🧭 Updated UI Design Flow: Calendar-First Approach**

The navigation is now structured with a **Bottom Navigation Bar** with three main tabs to separate the immediate (Home) from the historical (History) and utility (Settings).

### **1\. Navigation Flow Update (3 Tabs)**

* **Tab 1: Home (Default):** Calendar view (The main landing page).  
* **Tab 2: History (New Tab):** Dedicated **Timeline View** for all past appointments.  
* **Tab 3: Settings:** For accessibility and language options.

### ---

**2\. Home Screen (Calendar View) 🗓️**

This screen combines the calendar and the next appointment summary, using the high-contrast card and timeline style from the reference image.

| Element | Requirement Implementation | UI/UX Best Practice & Rationale |
| :---- | :---- | :---- |
| **Top Bar** | Title: **APPOINTMENTS**. Settings icon $(\\mathbf{\\clubsuit})$ for quick access. User Profile image (optional/decorative). | Consistent top-bar styling with high-contrast text. |
| **Calendar View** | Display the current month (e.g., **2025 Dec**). Dates of saved/upcoming appointments must be **prominently highlighted** (e.g., orange circle around the date, similar to the reference image). | **Core Requirement Met.** Allows quick visual identification of appointment days. Flutter's TableCalendar is ideal here. |
| **Interaction** | **Clicking a Highlighted Date:** Triggers a refresh of the **Appointment Details Card** below to show appointments for that specific date. | Enables fast switching between upcoming dates. |
| **Appointment Details Card** | Titled **"Next Appointment"** (if the selected date is today/future) or **"Appointments on \[Date\]"** (if the selected date is in the past). | Uses a large, high-contrast card area below the calendar. |
| **Recording Action** | A prominent **"Start Recording"** button positioned right below the title of the next appointment card. This button is only visible if the selected appointment is current or within a time window (e.g., 30 minutes before start time). | **Core Requirement Met.** Provides immediate access to the recording feature in the context of the upcoming visit. |
| **FAB (Floating Action Button)** | Large, central FAB with a plus (+) icon and text **"New Appointment"** or **"Add"**. Tapping this navigates to the **Add New Appointment Screen**. | Clear, simple call-to-action for adding logs. |

### ---

**3\. Add New Appointment Screen ➕**

This screen follows the input style shown on the right side of your reference image (clean, white cards with clear fields).

| Element | Requirement Implementation | UI/UX Best Practice & Rationale |
| :---- | :---- | :---- |
| **Navigation** | Back button $(\\mathbf{\<})$ to return to the Home Screen. Title: **Add Appointment**. | Simple, linear navigation. |
| **Input Fields** | Organized into clear sections: | Uses the clean card style of the reference image. |
|  | **1\. Date & Time:** Picker component (Crucial for calendar highlight). |  |
|  | **2\. Venue/Hospital:** Text input. |  |
|  | **3\. Dr. Name:** Text input (optional). |  |
|  | **4\. Remarks/Note:** Large multi-line text area. |  |
| **Save Action** | Large, high-contrast button: **"Save Date"** (as per the reference image) or **"Save Appointment"**. | **Upon Save:** Save to Hive, highlight the date on the Home Calendar, and navigate back to the Home Screen. |

### ---

**4\. Appointment History Screen (New Tab) 📜**

This is the dedicated log screen for all past recordings and summaries.

| Element | Requirement Implementation | UI/UX Best Practice & Rationale |
| :---- | :---- | :---- |
| **View** | **Timeline/List View** (Reverse Chronological). | Better for scanning long historical lists than a calendar. |
| **History Cards** | Each card displays: **Date, Dr. Name, Summary Status (e.g., "Summary Ready")**. | The cards are tappable to navigate to the **Consultation Detail Screen**. |
| **Details vs. Summary** | Since past appointments are saved in history, this screen lists all of them, regardless of whether they have a recording/summary. | Provides a comprehensive log. |

### **5\. Consultation Detail Screen (Review)**

(This remains the same as the previous design, accessed by clicking a past appointment from the **History Screen** or by clicking a past date on the **Home Calendar**.)

* **Focus:** Large, high-contrast **Summarized Text**.  
* **Action Panel:** Persistent, large buttons for **Read Summary**, **Original Audio**, and **Share Summary**.

This flow adheres to all your new requirements, adopts the clean, accessible style of your reference image, and fixes the navigation by clearly separating the "current planning" (Home) from the "past log" (History).