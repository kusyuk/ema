# ema

Elderly Medical Appointment (Assistant)
***For Cursor x Anthropic Hackathon Malaysia 2025***

This is the modified `README.md` in Markdown format, incorporating all your new sections and content while maintaining the project's accessibility focus.

# 📝 EMA - Elderly Medical Assistant

## Project Overview

**EMA** (Elderly Medical Assistant) is a cross-platform mobile application designed to bridge the communication gap between healthcare providers and elderly patients, ensuring crucial medical advice is never misunderstood or forgotten.

The app uses **Speech-to-Text (STT)** to record and transcribe doctor-patient consultations and then leverages a **Large Language Model (LLM)** to transform complex medical jargon into a simple, easy-to-understand summary written at a primary school reading level.

---

## 💡 Inspiration

My personal motivation for building EMA stems from a direct observation of this critical healthcare communication failure:

> **I saw my mom struggle to understand the doctor's explanation, sometimes forgot the crucial details, and could not explain to us well when she had an appointment with the doctor when I cannot accompany her for the sessions.**

This experience highlighted the urgent need for a tool that empowers elderly patients with clear, accessible, and shareable medical information, acting as a reliable memory and communication aid.

---

## ⚙️ What it does

EMA provides a seamless, end-to-end solution for managing and understanding medical visits:

1.  **Appointment Management:** Users can add and view appointments using a simple, calendar-first UI.
2.  **Consultation Recording:** A single, large button initiates the recording of the doctor-patient conversation.
3.  **Intelligent Summarization:** The raw audio is transcribed (STT) and immediately processed by the LLM (Groq) to generate a **3-point, simplified summary** (**Diagnosis, Action Plan, Next Appointment**) at a Grade 4 reading level.
4.  **Review & Share:** The summary can be read, listened to (TTS), or shared easily with family and caregivers.

---

## 🏗️ How we built it

| Component | Technology / Service | Implementation Details |
| :--- | :--- | :--- |
| **Mobile Platform** | **Flutter** (Dart) | Utilized for cross-platform deployment (iOS/Android) with an emphasis on **Accessible UI/UX** (High-Contrast, Large Targets). |
| **Architecture** | **Clean Architecture** (BLoC/Riverpod) | Structured the codebase into Presentation, Domain, and Data layers for maximum testability and maintainability when integrating external APIs. |
| **Summarization (LLM)** | **Groq API** (Mixtral/Llama 3) | Used a highly-optimized, **structured prompting strategy** to leverage Groq's low latency and speed up the summary generation process significantly. |
| **Transcription (STT)** | **ElevenLabs Scribe v1 / Groq ASR** | Integrated a robust STT solution to accurately capture medical terminology for processing. |
| **Local Storage** | **Hive** | Used for fast, lightweight local persistence of appointment logs and summarized text. |

---

## 🛑 Challenges we ran into

* **Prompt Engineering for Readability:** The biggest challenge was fine-tuning the Groq prompt to consistently produce summaries that were **medically accurate** while strictly adhering to the **Grade 4 (Layman's) reading level** without losing crucial context.
* **API Latency Management:** While Groq is fast, orchestrating the multi-step process (Audio Upload $\rightarrow$ Transcription $\rightarrow$ Summarization) while providing clear feedback to the user on the "Processing" screen required careful asynchronous state management in Flutter.
* **Accessibility Design:** Ensuring the **Calendar-first view** and **Timeline History** remained intuitive and easy to navigate for users with potential cognitive or dexterity limitations.

---

## ✅ Accomplishments that we're proud of

* **Finished the core functionalities of the app:** Successfully implementing the full pipeline from **Recording $\rightarrow$ Transcription $\rightarrow$ LLM Summarization $\rightarrow$ Display** into a functional mobile UI.
* **Established a high-contrast, accessible UI/UX** flow that prioritizes the unique needs of the elderly demographic.
* Integrating a modern, high-speed LLM service (Groq) to provide **near real-time summarization**, greatly enhancing the user experience.

---

## 🧠 What we learned

* **The full potential of Cursor:** Utilizing advanced code generation and editing tools to accelerate development and adhere to Clean Architecture standards.
* **Groq API:** Gaining hands-on experience in leveraging an ultra-low latency LLM for complex, real-time agentic tasks (like summarization) in a mobile context.
* **Proper 'vibe-coding' development process:** Successfully balancing rapid feature implementation with meticulous attention to security and architectural best practices.

---

## ⏭️ What's next for EMA - Elderly Medical Appointment (Assistant)

* **Polish the app** and refine the visual design to achieve a polished, production-ready aesthetic.
* **Enhance and expand the app functionality** with advanced AI features, such as:
    * **AI image recognition** to automatically log medicine information and schedule reminders based on the medicine picture (e.g., dosage, frequency).
* **Expand the sharing feature or add user & family account** functionality to make the appointment sharing session easier and create a centralized hub for caregiver coordination.
