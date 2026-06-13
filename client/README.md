<div align="center">
  <h1>🌏 TN-Epic: The Infinite Quest</h1>
  <p><em>A State-Scale "Phygital" Experience OS for Tamil Nadu Tourism</em></p>
  <p>
    <img src="https://img.shields.io/badge/Status-Prototyping-orange" alt="Status" />
    <img src="https://img.shields.io/badge/Architecture-Hybrid%20Microservices-blue" alt="Architecture" />
    <img src="https://img.shields.io/badge/AI-Agentic%20%2B%20RAG-brightgreen" alt="AI" />
  </p>
</div>

<br/>

> **"We are not building an app; we are building a State-Scale Economic Operating System. We monetize the Transaction, we own the Data, and we provide the Viral Vibe that Gen Z craves."**

TN-Epic transforms the physical geography of Tamil Nadu into a massive, interactive digital game board. By layering Augmented Reality (AR) and Agentic AI over the real world, this platform natively rewards tourists for exploring local culture and performing civic duties.

---

## ⚠️ The "Triple-Crisis" in Tourism

1. **Economic Leakage:** ~80% of tourist spending goes to global tech aggregators, leaving local MSMEs and artisans invisible.
2. **The Gen Z Disconnect:** Heritage sites are viewed as "static", causing average stays to drop below 1.8 days in key zones.
3. **The Civic Burden:** Peak tourism creates a 40% spike in plastic waste, costing the government ₹1,200 Crores annually in sanitation.

---

## ✨ Core Innovations

### 🗺️ The AR "Golden Path" (VPS Navigation)
Instead of a flat 2D map, TN-Epic uses a Visual Positioning System (VPS) through the smartphone's front camera to draw a 3D glowing path directly on the physical street. The AI dynamically reroutes this path based on real-time crowd heatmaps to prevent temple overcrowding.

### 🏪 The "Save Point" Merchant Economy
To secure in-game progress and "Explorer Streaks," tourists must physically visit verified local MSMEs (tea stalls, artisans). This creates **guaranteed footfall** for local businesses, who can bid in real-time to have the Golden Path curve toward their shops.

### ♻️ Dharma Points & IoT Smart Bins
Tourists earn "Temple Points" (Dharma Score) for civic duties. Using Python-based Computer Vision and IoT (ESP32), the system verifies when a user throws plastic into a Smart Bin or eats at an authentic local restaurant (granting a 3x point multiplier).

### 🎭 Vlogger-First AR Landmarkers
Completing quests unlocks exclusive, location-locked AR filters (e.g., a glowing 3D Chola Crown at the Big Temple). This turns tourists into a viral, free marketing engine.

### 🤖 Hallucination-Free Agentic AI
An AI guide orchestrated via a Retrieval-Augmented Generation (RAG) architecture anchored to official Tamil Heritage APIs provides 100% accurate historical context and acts as a dynamic "Quest Re-Orchestrator."

---

## 🏗️ The "Zenovox" Engine Architecture

Built for state-scale traffic, TN-Epic utilizes a highly decoupled, event-driven hybrid microservice architecture integrating AI, AR, and IoT.

| Layer | Technologies | Purpose |
| :--- | :--- | :--- |
| **Edge / Client** | Flutter, C++ (ARCore), TFLite | Zero-latency 3D spatial mapping and UI |
| **Logic & Ledger**| Java 21, Spring Boot 3.4 | Mission-critical financial ledger & ACID compliance |
| **AI & Vision** | Python, YOLOv8, LangGraph | Real-world object verification & Agentic coordination |
| **Event Spine** | Apache Kafka, WebSockets | State-scale event streaming & real-time B2B bidding |
| **Database** | PostgreSQL (PostGIS), Redis | Geospatial persistence and millisecond caching |
| **Social Graph** | Neo4j, Milvus | Clan relationship mapping & vector AI memory |

---

## 📱 Frontend Client Details (`/frontend/client`)

The client-side edge application features a dual-engine architecture handling real-time cross-platform user interfaces and native low-latency Augmented Reality (AR) spatial rendering.

### Core Client Modules
1. **Flutter UI (HUD & Lobby):** Manages high-performance transitions for user profiling screens, interactive level-maps, social clan interactions, and dynamic in-game heads-up display (HUD) elements at 60fps.
2. **Spatial Navigation Engine (AR Engine):** Built with Native C++ and ARCore Geospatial API. Directly taps into hardware IMU sensors and the GPU to draw the glowing 3D "Golden Path" on physical streets with sub-10cm precision while maximizing battery efficiency.
3. **Edge AI Inference Engine:** Uses TensorFlow Lite (TFLite) & ONNX Runtime to execute hardware-accelerated computer vision models natively on the phone's Neural Processing Unit (NPU) for zero-latency detection of smart bins and authentic regional food items.
4. **Dead-Zone Survival Module (Offline Sync):** Uses C++ & Embedded SQLite to pre-cache vector tiles and 3D assets for a 2km zone. It safely buffers gameplay actions inside ancient thick-walled heritage monuments or hill stations, batch-syncing them when connectivity resumes.

### Mobile-Edge Optimizations
To handle heavy graphics, AI inference, and live navigation without killing device batteries, the client follows strict engineering guardrails:
* **Level of Detail (LOD):** Simplifies poly-counts and asset fidelity dynamically based on distance.
* **Dynamic GPS Throttling:** Reduces location polling intervals automatically whenever a user is stationary inside a partnered "Save Point".
* **GPU Frame Capping:** Locks the AR camera interface tightly at 30 FPS to reduce overall GPU heat and drain by roughly 40%.

---

## 🚀 Getting Started

### Prerequisites
Make sure your development machine has the following tools installed:
* **Flutter SDK:** ^3.22.0 or higher
* **Android SDK / NDK:** Required for custom native C++ AR compilation
* **Physical Device:** A device supporting ARCore (Android) or ARKit (iOS) with working camera/IMU sensors. *(Note: AR components will not run properly on virtual emulators).*
