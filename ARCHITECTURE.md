
FaceAttend System Architecture

┌─────────────────┐    Offline/Sync    ┌──────────────────┐
│ Mobile App      │◄──────────────────►│   Backend API    │
│ (Flutter)       │    HTTP/REST       │ (Node.js/Express)│
│                 │                    │                  │
│  - Camera       │                    │  - Auth          │
│  - Face Rec     │                    │  - Employee CRUD │
│  - SQLite DB    │◄──────────────────►│  - Attendance    │
│  - Sync Queue   │   Online/Sync      │  - MongoDB       │
└─────────────────┘                    └──────────────────┘
        ▲                                       ▲
        │                                       │
        │     Flutter Web (Code Sharing)        │
        │                                       │
┌─────────────────┐                    ┌──────────────────┐
│ Admin Panel     │◄──────────────────►│   Backend API    │
│ (Flutter Web)   │    HTTP/REST       │ (Same Instance)  │
│                 │                    │                  │
│  - Dashboard    │                    │                  │
│  - Employee Mgmt│                    │                  │
│  - Reports      │                    │                  │
│  - Settings     │                    │                  │
└─────────────────┘                    └──────────────────┘

Key:
- All components communicate via REST API
- Mobile app works offline-first with local SQLite
- Sync queue handles offline operations
- Admin panel shares code with mobile app (Flutter Web)
- Backend uses MongoDB for persistent storage
