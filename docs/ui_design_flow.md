This UI design flow focuses on **simplicity, clarity, and accessibility** for your target elderly user group, following mobile and Flutter best practices.

The flow is structured around the core user journey: **Logging a Visit** and **Reviewing History**.

## **🗺️ High-Level App Flow**

The navigation is designed to be **flat and shallow** to prevent users from getting lost.

1. **Appointments (Home/Timeline):** The default screen for adding a new appointment, viewing history and upcoming visits.  
2. **Reminders:** Dedicated screen for medication and next visit reminders.  
3. **Settings:** For crucial accessibility and language customisation.

## ---

**🧭 Detailed Screen Flow & UI/UX**

### **1\. Appointments Screen (Home/Timeline View)**

This is the primary screen users see upon opening the app.

| Element | UI/UX Best Practice & Rationale |
| :---- | :---- |
| **View** | **Timeline/List View** (Reverse Chronological). Most appointments are in the past; this view is easier to scan than a calendar. |
| **Top Bar** | Large title: **APPOINTMENTS**. Small **Settings icon** $(\\mathbf{\\clubsuit})$ (access via Bottom Nav too, for redundancy). |
| **Upcoming Card** | **Always Pinned to Top.** Large, high-contrast card showing the date and time of the next visit. Contains a prominent **"Add to Calendar"** button. |
| **New Consultation Button** | A large, central **Floating Action Button (FAB)** with a plus (+) icon and the text **"Start Visit"** or **"Record"**. It should be easy to find and tap. |
| **Past Cards** | Each card is a summary of a visit: **Date, Dr. Name, Reason.** Tapping the card opens the **Consultation Detail** screen. |

### ---

**2\. Consultation Recording Flow (Core Feature)**

This flow must be extremely clear due to the sensitivity of audio recording.

| Step | Screen/Interaction | UI/UX Best Practice & Rationale |
| :---- | :---- | :---- |
| **A. Start** | User taps **"Start Visit"** FAB. | Instant, clear feedback. |
| **B. Consent & Context** | **Full-Screen Modal/Pop-up** with very large text. Title: **"Ready to Record?"** Body: "By tapping 'Start', you confirm the doctor has consented to the recording." | **Crucial Legal/Ethical Step.** User must acknowledge consent before proceeding. Include a field for **Dr. Name** and **Reason for Visit**. |
| **C. Active Recording** | **Dedicated Recording Screen.** Dominant feature: A very large, high-contrast **STOP** button (Square icon) and a clear timer. A banner must say: **"RECORDING ACTIVE \- DO NOT CLOSE APP."** | Simple, single-purpose screen to prevent accidental interruption. High contrast on the STOP button. |
| **D. Processing** | Upon tapping STOP, transition to a **Loading Screen**. Display the steps in a checklist: **1\. Audio Saved $\\checkmark$, 2\. Transcribing... (Active), 3\. Summarizing...** | **Provides Feedback on Progress.** Since LLM and STT can take time (5-30s), this reassures the user that the app is working. |
| **E. Finish** | Automatically navigate to the new **Consultation Detail Screen** with the summary ready. | Immediate reward/feedback. |

### ---

**3\. Consultation Detail Screen (Review)**

The goal here is immediate access to the simplified summary and the crucial action buttons.

| Element | UI/UX Best Practice & Rationale |
| :---- | :---- |
| **Display** | **The Summarized Text is the main focus.** It should be displayed in a very large, high-contrast font, optimized for reading. |
| **Action Panel** | A persistent section (e.g., at the bottom of the screen) containing the three key actions as large, redundant icons: |
|  | 1\. **Read Summary** (Speaker Icon \+ Text) |
|  | 2\. **Original Audio** (Microphone Icon \+ Text) |
|  | 3\. **Share Summary** (Share Icon \+ Text) |
| **Data Log** | A collapsible section for metadata (Dr. Name, Hospital, Date/Time). |

### ---

**4\. Settings Screen (Accessibility Focus)**

This screen manages the critical customization aspects for elderly users.

| Setting Group | Configuration Option | UI/UX Best Practice & Rationale |
| :---- | :---- | :---- |
| **Accessibility** | **Theme:** Toggle Light/Dark Mode (default Dark). **Text Size:** Slider or predefined options (Standard, Large, Extra Large). | Direct control over visual aids is non-negotiable for this demographic. |
| **Language** | **Preferred Summary Language:** Dropdown/List (e.g., English, Chinese, Malay). | Crucial for the Groq LLM prompt strategy; ensures the output is in the user's most comfortable language. |
| **Privacy & Data** | **Consent Log:** View the legal privacy policy and recording consent history. **Export Data:** Option to export all log data. | Builds trust and addresses legal/data ownership concerns. |

This flow emphasizes a **frictionless core journey** while baking in **accessibility and privacy** features from the ground up, aligning with both Flutter design standards and elderly user needs.