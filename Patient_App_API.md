# Patient App API Documentation

**Base URL:** `http://148.230.114.124:8080`
**Version:** v1 | **Auth:** Firebase JWT (Bearer Token) | **Role:** `Patient`

---

## 1. Overview

This file documents all APIs used by the **Patient Mobile App** (Flutter).

Patients can:
- Register, sync profile, and complete onboarding
- Search for drugs in the global catalog
- Browse and find pharmacies
- Create orders for drugs (with or without prescriptions)
- Upload prescriptions and track order status in real time
- Confirm or cancel pricing sent by pharmacies
- Request a personal pharmacist
- View medication plans and set reminders
- Track health readings (blood pressure, sugar, weight)
- Manage medical history: conditions, diseases, allergies, lab results, scans
- Upload and delete medical documents
- Receive push notifications for all order and account events

> ⚠️ All endpoints require a valid Firebase token. The user must have the `Patient` role.
> ⚠️ Inventory is **NOT used**. Orders are fulfilled directly from the global Drug Catalog.
> ⚠️ Drug pricing is **dynamic** — pharmacy sets the price for each order.

---

## 2. Authentication Flow

### Step 1 — Firebase Login
Patient registers or logs in using Firebase (email/password or Google/Apple).
Firebase returns an **ID Token** (JWT), valid for **1 hour**.

> Use Firebase SDK: `user.getIdToken()` to get the token.
> Use `user.getIdToken(true)` to force refresh when expired.

### Step 2 — Sync User with Backend
```
POST http://148.230.114.124:8080/api/v1/users/sync
```
**Headers:**
```
Authorization: Bearer {firebase_id_token}
Content-Type: application/json
```
**Request Body:**
```json
{
  "email": "patient@example.com",
  "name": "Ahmed Ali",
  "displayName": "Ahmed",
  "phoneNumber": "+201234567890"
}
```
**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "patient-guid",
    "firebaseUid": "firebase_uid_here",
    "email": "patient@example.com",
    "name": "Ahmed Ali",
    "roles": ["Patient"],
    "status": "Active",
    "isNewUser": true
  },
  "errors": []
}
```

> ⚠️ **CRITICAL ONBOARDING FLOW FOR FRONTEND:**
> 1. `/users/sync` is purely for **bootstrapping** and confirming the account exists in SQL.
> 2. **Temporary Name Fallback:** If you do not send `name` or `displayName` in the request body (which is normal for new Firebase Email/Password signups), the backend will temporarily save the user's `email` in the `name` field to prevent database errors.
> 3. If the response returns `isNewUser = true` (or if the `name` returned is exactly equal to the `email`), you **MUST** navigate the user to a "Complete Profile" screen.
> 4. In that screen, collect their real name and call `POST /api/v1/users/profile/complete`. This is the **Source of Truth** and will permanently fix the fallback name.
> Save the `id` (internal user ID) from the response — you may need it in other calls.

### Step 3 — Get Full Profile
```
GET http://148.230.114.124:8080/api/v1/users/me
```
**Headers:**
```
Authorization: Bearer {firebase_id_token}
```
**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "patient-guid",
    "firebaseUid": "firebase_uid_here",
    "email": "patient@example.com",
    "name": "Ahmed Ali",
    "phone": "+201234567890",
    "gender": "Male",
    "dateOfBirth": "1995-06-15",
    "avatarUrl": "https://example.com/avatar.jpg",
    "roles": ["Patient"],
    "membershipNumber": null,
    "status": "Active",
    "createdAt": "2026-04-01T10:00:00Z"
  }
}
```

---

## 3. Profile Management

### POST /api/v1/users/profile/complete
**First-time profile setup.** Call this once after registration/sync when `isNewUser = true`.

> ⚠️ **Data Ownership Rule:** `/api/v1/users/sync` acts as a **bootstrap only** (it will never overwrite existing data if the user has already provided it). `/api/v1/users/profile/complete` is the **absolute source of truth**. It is idempotent, safe to call multiple times, and the last user-provided value will always win.

**When to call:** Immediately after sync if `isNewUser = true`. Show an onboarding screen.
**UI on success:** Navigate to home screen.
**UI on failure (400):** Show field-level validation errors inline.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```
**Request Body:**
```json
{
  "name": "Ahmed Ali",
  "phone": "+201234567890",
  "gender": "Male",
  "dateOfBirth": "1995-06-15",
  "avatarUrl": "https://cdn.example.com/avatar.jpg"
}
```

**Validation Rules:**
| Field | Rule |
|---|---|
| `name` | Required, max 100 characters |
| `phone` | Optional, must be valid international format |
| `gender` | Optional — must be exactly `Male`, `Female`, or `Other` |
| `dateOfBirth` | Optional — must be a past date (YYYY-MM-DD) |
| `avatarUrl` | Optional — must be a valid absolute URL (https://) |

**Response 200:** Returns updated `UserProfileResponse` (same as `GET /users/me`).

**Errors:**
| Code | UI Behavior |
|------|-------------|
| 400 | Show specific validation message under each field |
| 401 | Redirect to login screen |

---

### PUT /api/v1/users/me
Update profile fields at any time (not just first login).

**Request Body:**
```json
{
  "name": "Ahmed Ali Updated",
  "phone": "+201234567890",
  "gender": "Male",
  "dateOfBirth": "1995-06-15",
  "avatarUrl": "https://example.com/new_avatar.jpg"
}
```
> `name` is required. All other fields are optional.

**Response 200:** Returns updated `UserProfileResponse`.

### DELETE /api/v1/users/me
Permanently deletes the account. No body required. Show a confirmation dialog before calling.

---

## 4. Delivery Addresses

### GET /api/v1/users/me/addresses
Get all saved delivery addresses.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "address-guid",
        "label": "Home",
        "street": "123 Tahrir St",
        "city": "Cairo",
        "governorate": "Cairo",
        "latitude": 30.044,
        "longitude": 31.235,
        "isDefault": true
      }
    ],
    "totalCount": 1
  }
}
```

### POST /api/v1/users/me/addresses
Add a new address.

**Request Body:**
```json
{
  "label": "Home",
  "street": "123 Tahrir St",
  "city": "Cairo",
  "governorate": "Cairo",
  "latitude": 30.044,
  "longitude": 31.235
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "address-guid",
    "label": "Home",
    "street": "123 Tahrir St",
    "city": "Cairo",
    "governorate": "Cairo",
    "latitude": 30.044,
    "longitude": 31.235,
    "isDefault": true
  }
}
```

### PATCH /api/v1/users/me/addresses/{addressId}/default
Set an address as default. No body required.

### DELETE /api/v1/users/me/addresses/{addressId}
Remove an address.

---

## 5. Device Registration (Push Notifications)

Register the device so the patient receives push notifications.

### POST /api/v1/users/me/devices
**Request Body:**
```json
{
  "fcmToken": "firebase_cloud_messaging_token_here",
  "platform": "android"
}
```
> `platform` values: `android`, `ios`

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "device-guid",
    "fcmToken": "token_here",
    "platform": "android",
    "registeredAt": "2026-04-22T10:00:00Z"
  }
}
```

### GET /api/v1/users/me/devices
Get all registered devices.

### DELETE /api/v1/users/me/devices/{deviceId}
Remove a device (e.g., on logout).

---

## 6. File Upload

Upload a file (prescription image, medical document, etc.) before attaching to requests.

### POST /api/files/upload
**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```
**Form Data:**
```
file: [binary image or PDF]
type: Prescription
```

> `type` values: `Prescription`, `LabResult`, `XRay`, `MedicalReport`, `License`, `Identification`, `InsuranceCard`, `Invoice`, `Other`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "file-guid",
    "fileKey": "uploads/2026/04/prescription_abc.jpg",
    "url": "https://s3.amazonaws.com/pharmacare/uploads/2026/04/prescription_abc.jpg",
    "type": "Prescription",
    "status": "Pending",
    "ownerId": "patient-guid"
  }
}
```

> Save the returned `url` — you will pass it to the orders or prescriptions endpoint.

### GET /api/files/my
Get all files uploaded by this patient.

### GET /api/files/{id}
Get a specific file.

### DELETE /api/files/{id}
Delete a file.

---

## 7. Drug Search & Discovery

> ⚠️ Use `/api/v1/drugs/*` — NOT the legacy `/api/v1/medicines/*` or `/api/v1/search/medicines`.

### GET /api/v1/drugs/search
Search for drugs by name.

**Query Params:** `?q=panadol&page=1&pageSize=20`

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "drug-guid",
        "name": "Panadol",
        "dosage": "500mg",
        "imageUrl": "https://example.com/panadol.jpg",
        "requiresPrescription": false,
        "isControlled": false
      }
    ],
    "totalCount": 1,
    "page": 1,
    "pageSize": 20,
    "totalPages": 1
  }
}
```

> If `requiresPrescription = true` → Show warning and require prescription upload before ordering.
> If `isControlled = true` → Show controlled substance warning.

### GET /api/v1/drugs/{id}
Get full drug details.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "drug-guid",
    "name": "Panadol",
    "activeIngredient": "Paracetamol",
    "form": "Tablet",
    "dosage": "500mg",
    "description": "Pain reliever and fever reducer",
    "warnings": "Do not exceed 4g per day. Avoid alcohol.",
    "imageUrl": "https://example.com/panadol.jpg",
    "requiresPrescription": false,
    "isControlled": false,
    "isSensitive": false
  }
}
```

---

## 8. Pharmacy Discovery

### GET /api/v1/pharmacies
Browse all approved pharmacies.

**Query Params:** `?page=1&pageSize=20`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "pharmacy-guid",
        "name": "Al Seha Pharmacy",
        "registrationNumber": "REG-2024-001",
        "status": "Approved",
        "branchCount": 3,
        "createdAt": "2026-01-01T00:00:00Z"
      }
    ],
    "totalCount": 40
  }
}
```

### GET /api/v1/pharmacies/nearby
Find pharmacies near the patient's location.

**Query Params:** `?lat=30.044&lng=31.235&radiusKm=5`

### GET /api/v1/pharmacies/{id}
Get pharmacy details.

### GET /api/v1/pharmacies/governorates
Get list of governorates that have pharmacies.

### GET /api/v1/search/pharmacies
Search pharmacies by name or governorate.

**Query Params:** `?q=seha&governorate=Cairo`

---

## 9. Prescriptions

### POST /api/v1/prescriptions
Upload a prescription after uploading the image via `/api/files/upload`.

**Request Body:**
```json
{
  "doctorName": "Dr. Ahmed Hassan",
  "clinicName": "Cairo Medical Center",
  "issueDate": "2026-04-01",
  "expiryDate": "2026-07-01",
  "imageUrls": [
    "https://s3.amazonaws.com/pharmacare/uploads/rx1.jpg"
  ]
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "prescription-guid",
    "patientId": "patient-guid",
    "patientName": "Ahmed Ali",
    "doctorName": "Dr. Ahmed Hassan",
    "clinicName": "Cairo Medical Center",
    "issueDate": "2026-04-01",
    "expiryDate": "2026-07-01",
    "status": "Pending",
    "imageUrls": ["https://s3.amazonaws.com/pharmacare/uploads/rx1.jpg"],
    "review": null,
    "createdAt": "2026-04-22T09:00:00Z"
  }
}
```

### GET /api/v1/prescriptions/me
Get all my prescriptions.

### GET /api/v1/prescriptions/{id}
Get a single prescription.

---

## 10. Creating an Order

> ⚠️ Before creating an order:
> 1. Patient must have at least one saved delivery address
> 2. If any drug `requiresPrescription = true`, upload the prescription image first

### POST /api/v1/orders
**Headers:**
```
Authorization: Bearer {patient_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "pharmacyId": "pharmacy-guid",
  "deliveryAddressId": "address-guid",
  "prescriptionImageUrl": "https://s3.amazonaws.com/pharmacare/uploads/rx1.jpg",
  "deliveryNotes": "Leave at door. Ring twice.",
  "items": [
    {
      "drugId": "drug-guid-panadol",
      "quantity": 2
    },
    {
      "drugId": "drug-guid-metformin",
      "quantity": 1
    }
  ]
}
```

> `prescriptionImageUrl` — optional if no drug requires a prescription.
> `deliveryNotes` — optional, max 500 characters.
> `items` — required, minimum 1 item.

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "order-guid",
    "customerId": "patient-guid",
    "customerName": "Ahmed Ali",
    "pharmacyId": "pharmacy-guid",
    "pharmacyName": "Al Seha Pharmacy",
    "branchId": null,
    "branchName": "",
    "prescriptionImageUrl": "https://s3.amazonaws.com/pharmacare/uploads/rx1.jpg",
    "finalPrice": null,
    "respondedByPharmacyId": null,
    "orderStatus": "Pending",
    "paymentStatus": "Pending",
    "deliveryNotes": "Leave at door. Ring twice.",
    "items": [
      {
        "drugId": "drug-guid-panadol",
        "drugName": "Panadol",
        "dosage": "500mg",
        "form": "Tablet",
        "imageUrl": "https://example.com/panadol.jpg",
        "requiresPrescription": false,
        "isControlled": false,
        "quantity": 2,
        "unitPrice": null
      }
    ],
    "statusHistory": [],
    "createdAt": "2026-04-22T10:00:00Z",
    "updatedAt": null
  }
}
```

> After creation:
> - Order status = `Pending`
> - Pharmacy receives a `NEW_ORDER` push notification
> - Patient waits for pharmacy to respond

**Errors:**
| Code | Reason |
|------|--------|
| 400 | Missing items, invalid drugId or addressId |
| 401 | Token missing or expired |
| 404 | Pharmacy or drug not found |
| 422 | Drug is not active or prescription required but not provided |

---

## 11. Tracking Orders

### GET /api/v1/orders/my
Get all orders placed by this patient.

**Query Params:** `?page=1&pageSize=20`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "order-guid",
        "pharmacyName": "Al Seha Pharmacy",
        "orderStatus": "PricingResponded",
        "finalPrice": 125.50,
        "items": [
          { "drugName": "Panadol", "quantity": 2 }
        ],
        "createdAt": "2026-04-22T10:00:00Z"
      }
    ],
    "totalCount": 5,
    "page": 1,
    "pageSize": 20
  }
}
```

### GET /api/v1/orders/{id}
Get full order details including status history.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "order-guid",
    "orderStatus": "PricingResponded",
    "finalPrice": 125.50,
    "statusHistory": [
      {
        "id": "history-guid",
        "status": "Pending",
        "comments": "",
        "changedByName": "System",
        "changedAt": "2026-04-22T10:00:00Z"
      },
      {
        "id": "history-guid-2",
        "status": "PricingResponded",
        "comments": "All items available. Delivery: 2 hours.",
        "changedByName": "Al Seha Pharmacy",
        "changedAt": "2026-04-22T10:30:00Z"
      }
    ]
  }
}
```

---

## 12. Confirming or Cancelling an Order

### POST /api/v1/orders/{id}/confirm
Patient confirms the price offered by the pharmacy.

**No request body.**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "order-guid",
    "orderStatus": "Confirmed",
    "finalPrice": 125.50
  }
}
```

> After confirmation:
> - Order status → `Confirmed`
> - Pharmacy receives `ORDER_CONFIRMED` push notification

**Errors:**
| Code | Reason |
|------|--------|
| 422 | Order is not in `PricingResponded` status |

### DELETE /api/v1/orders/{id}/cancel
Patient cancels the order.

**No request body.**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "order-guid",
    "orderStatus": "Cancelled"
  }
}
```

> Only possible when order status is `Pending`.

---

## 13. Notifications (Patient)

### GET /api/v1/notifications
**Query Params:** `?page=1&pageSize=20`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "notif-guid",
        "userId": "patient-guid",
        "title": "Order Priced",
        "body": "Al Seha Pharmacy responded to your order: 125.50 EGP",
        "type": "ORDER_RESPONSE",
        "isRead": false,
        "createdAt": "2026-04-22T10:30:00Z"
      }
    ],
    "totalCount": 3,
    "page": 1,
    "pageSize": 20
  }
}
```

### GET /api/v1/notifications/unread-count
```json
{ "success": true, "data": 3 }
```

### PUT /api/v1/notifications/{id}/read
Mark a notification as read.

### Notification Types Patient Receives

| Type | When | Action |
|------|------|--------|
| `ORDER_RESPONSE` | Pharmacy accepted with price | Navigate to order detail → show price → allow confirm/cancel |
| `ORDER_CONFIRMED` | N/A for patient (pharmacy receives this) | — |
| `APPLICATION_APPROVED` | N/A for patient | — |

**FCM Push Payload:**
```json
{
  "notification": {
    "title": "Order Priced",
    "body": "Al Seha Pharmacy responded: 125.50 EGP"
  },
  "data": {
    "type": "ORDER_RESPONSE",
    "orderId": "order-guid",
    "pharmacyName": "Al Seha Pharmacy",
    "price": "125.50"
  }
}
```

---

## 14. Request a Personal Pharmacist

### GET /api/v1/patients/pharmacists
Browse available pharmacists to request.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "pharmacist-guid",
        "name": "Dr. Khaled Hassan",
        "specialization": "Clinical Pharmacy",
        "averageRating": 4.7,
        "totalPatients": 24,
        "isAcceptingPatients": true
      }
    ]
  }
}
```

### POST /api/v1/patients/request-pharmacist
```json
{
  "pharmacistId": "pharmacist-guid",
  "message": "I need help managing my diabetes medication"
}
```

### GET /api/v1/patients/my-requests
Get all my pharmacist requests.

### DELETE /api/v1/patients/requests/{id}/cancel
Cancel a pending pharmacist request.

---

## 15. Medication Plans (Patient View)

### GET /api/v1/medications
Get all medication plans assigned to me.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "plan-guid",
        "patientId": "patient-guid",
        "patientName": "Ahmed Ali",
        "pharmacistId": "pharmacist-guid",
        "pharmacistName": "Dr. Khaled",
        "medicineName": "Metformin",
        "dosage": "500mg",
        "instructions": "Take with meals",
        "quantity": 60,
        "prescribingDoctor": "Dr. Hassan",
        "createdAt": "2026-04-22T10:00:00Z",
        "schedules": [
          {
            "id": "schedule-guid",
            "timeOfDay": "Morning",
            "frequency": "Daily",
            "startDate": "2026-04-22",
            "endDate": "2026-05-22"
          }
        ]
      }
    ]
  }
}
```

### GET /api/v1/medications/{id}
Get a specific medication plan.

### POST /api/v1/medications/log
Log that a medication dose was taken, missed, or skipped.

```json
{
  "scheduleId": "schedule-guid",
  "status": "Taken",
  "takenAt": "2026-04-22T08:00:00Z",
  "notes": "Taken with a glass of water"
}
```

> `status` values: `Taken`, `Missed`, `Skipped`

### GET /api/v1/medications/adherence
Get adherence summary.

```json
{
  "success": true,
  "data": {
    "totalDoses": 30,
    "takenDoses": 25,
    "missedDoses": 3,
    "skippedDoses": 2,
    "adherencePercentage": 83.33
  }
}
```

### GET /api/v1/medications/logs
Get full log history of medication intake.

---

## 16. Reminders

### POST /api/v1/reminders
Create a medication reminder.

```json
{
  "type": "Medication",
  "relatedEntityId": "plan-guid",
  "title": "Take Metformin",
  "description": "500mg with breakfast",
  "frequencyType": "Daily",
  "intervalHours": 24,
  "startTime": "2026-04-22T08:00:00Z",
  "endTime": "2026-05-22T08:00:00Z"
}
```

### GET /api/v1/reminders
Get all reminders.

### POST /api/v1/reminders/{id}/taken
Mark reminder as taken.

### POST /api/v1/reminders/{id}/skip
Mark reminder as skipped.

### POST /api/v1/reminders/{id}/snooze
```json
{ "minutes": 15 }
```

---

## 17. Health Readings

Record measurable vitals over time. Used for trend charts and risk scoring.

### POST /api/v1/health-readings
**When to call:** When patient submits a new reading from the health screen.

```json
{
  "type": "BloodPressure",
  "value": 120.0,
  "notes": "Fasting reading"
}
```

**Validation Rules:**
| Field | Rule |
|---|---|
| `type` | Required — must be `BloodPressure`, `Sugar`, or `Weight` |
| `value` | Required — must be positive number |
| `notes` | Optional — max 500 characters |

**Unit conventions:**
- `BloodPressure` → mmHg
- `Sugar` → mg/dL
- `Weight` → kg

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "reading-guid",
    "userId": "patient-guid",
    "type": "BloodPressure",
    "value": 120.0,
    "notes": "Fasting reading",
    "createdAt": "2026-04-22T08:00:00Z"
  }
}
```

### GET /api/v1/health-readings
**Query Params:** `?page=1&pageSize=20`
Returns all readings newest first.

### GET /api/v1/health-readings/history
Returns per-type statistical summary (min, max, avg, latest, last 10 readings).

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "type": "BloodPressure",
      "totalReadings": 15,
      "latestValue": 120.0,
      "latestReadingAt": "2026-04-22T08:00:00Z",
      "minValue": 110.0,
      "maxValue": 135.0,
      "averageValue": 121.5,
      "recentReadings": [
        { "id": "r-guid", "type": "BloodPressure", "value": 120.0, "createdAt": "2026-04-22T08:00:00Z" }
      ]
    }
  ]
}
```

> Use `history` for trend charts. Use `GET /health-readings` for a full list.

---

## 18. Medical Records & Patient History

The medical history system has two independent parts:
1. **Medical Records** — uploaded files (lab results, scans, reports) with structured metadata
2. **Patient Conditions** — structured chronic diseases and allergies (no file required)

> ⚠️ These are separate from health readings (blood pressure, sugar, weight).

---

### Two-Step File Upload Flow

Before creating a medical record you must upload the file first:

**Step 1 — Upload the file:**
```
POST /api/files/upload
Content-Type: multipart/form-data

file: [binary PDF/image]
fileType: LabResult   ← use: LabResult | XRay | MedicalReport
```
Save the returned `url`.

**Step 2 — Create the medical record with the URL:**
```
POST /api/v1/medical-records
```

---

### POST /api/v1/medical-records
Create a new medical record entry.

**When to call:** After file upload completes. Pass the `url` returned from upload.
**UI on success:** Add new card to medical history timeline. Show title + date.
**UI on failure (400):** Show error under the relevant field.

```json
{
  "fileUrl": "https://s3.amazonaws.com/pharmacare/uploads/cbc.pdf",
  "type": "LabResult",
  "title": "Complete Blood Count",
  "recordDate": "2026-04-01",
  "notes": "All results within normal range."
}
```

**Validation Rules:**
| Field | Rule |
|---|---|
| `fileUrl` | Required — must be a URL returned from `/api/files/upload` |
| `type` | Required — `LabResult`, `Report`, or `Scan` |
| `title` | Optional — max 200 characters. Shown on timeline card. |
| `recordDate` | Optional — YYYY-MM-DD format. Must NOT be in the future. This is the actual test date, not the upload date. |
| `notes` | Optional — max 2000 characters |

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "record-guid",
    "userId": "patient-guid",
    "fileUrl": "https://s3.amazonaws.com/pharmacare/uploads/cbc.pdf",
    "type": "LabResult",
    "title": "Complete Blood Count",
    "recordDate": "2026-04-01",
    "notes": "All results within normal range.",
    "createdAt": "2026-04-22T10:00:00Z"
  }
}
```

### GET /api/v1/medical-records
Get all medical records for this patient, sorted by `recordDate` DESC (falls back to `createdAt`).

**Query Params:**
| Param | Values | Description |
|---|---|---|
| `type` | `LabResult`, `Report`, `Scan` | Filter by record type (optional) |
| `page` | integer | Default: 1 |
| `pageSize` | integer | Default: 20, max: 100 |

**Example:** `GET /api/v1/medical-records?type=LabResult&page=1&pageSize=20`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "record-guid",
        "userId": "patient-guid",
        "fileUrl": "https://s3.amazonaws.com/pharmacare/uploads/cbc.pdf",
        "type": "LabResult",
        "title": "Complete Blood Count",
        "recordDate": "2026-04-01",
        "notes": "All results within normal range.",
        "createdAt": "2026-04-22T10:00:00Z"
      }
    ],
    "totalCount": 8,
    "page": 1,
    "pageSize": 20,
    "totalPages": 1
  }
}
```

### DELETE /api/v1/medical-records/{id}
Soft-delete a medical record. Only the owning patient can delete their records.

**When to call:** When patient taps "Delete" on a record card. Show confirmation dialog first.
**UI on success:** Remove card from timeline immediately (optimistic update).
**UI on failure (404):** Show "Record not found or already deleted".

**Response 200:**
```json
{ "success": true, "message": "Medical record deleted." }
```

---

## 19. Patient Conditions (Diseases & Allergies)

Structured conditions — no file upload required. Used to build the patient's permanent medical profile.

### POST /api/v1/patients/conditions
Add a chronic disease or allergy.

**When to call:** When patient fills out the "Add Condition" form.
**UI on success:** Add condition card to the conditions list.
**UI on failure (400):** Show validation error under the `name` or `type` field.

```json
{
  "type": "ChronicDisease",
  "name": "Type 2 Diabetes",
  "description": "Diagnosed in 2019, managed with Metformin 500mg",
  "diagnosedAt": "2019-03-15"
}
```

**Validation Rules:**
| Field | Rule |
|---|---|
| `type` | Required — `ChronicDisease` or `Allergy` |
| `name` | Required — max 200 characters |
| `description` | Optional — max 1000 characters |
| `diagnosedAt` | Optional — YYYY-MM-DD, must NOT be in the future |

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "condition-guid",
    "patientId": "patient-guid",
    "type": "ChronicDisease",
    "name": "Type 2 Diabetes",
    "description": "Diagnosed in 2019, managed with Metformin 500mg",
    "diagnosedAt": "2019-03-15",
    "createdAt": "2026-04-22T10:00:00Z"
  }
}
```

### GET /api/v1/patients/conditions
Get all active conditions for this patient.

**Query Params:**
| Param | Values | Description |
|---|---|---|
| `type` | `ChronicDisease`, `Allergy` | Filter by condition type (optional) |
| `page` | integer | Default: 1 |
| `pageSize` | integer | Default: 50 |

**Examples:**
- All conditions: `GET /api/v1/patients/conditions`
- Only allergies: `GET /api/v1/patients/conditions?type=Allergy`
- Only diseases: `GET /api/v1/patients/conditions?type=ChronicDisease`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "condition-guid",
        "patientId": "patient-guid",
        "type": "Allergy",
        "name": "Penicillin Allergy",
        "description": "Severe reaction — hives and swelling",
        "diagnosedAt": "2015-06-01",
        "createdAt": "2026-04-22T10:00:00Z"
      }
    ],
    "totalCount": 3,
    "page": 1,
    "pageSize": 50,
    "totalPages": 1
  }
}
```

### DELETE /api/v1/patients/conditions/{id}
Soft-delete a condition. Only the owning patient can delete.

**When to call:** When patient taps "Remove" on a condition card. Show confirmation dialog first.
**UI on success:** Remove card from list immediately.

**Response 200:**
```json
{ "success": true, "message": "Condition deleted." }
```

**Errors for Conditions & Medical Records:**
| Code | UI Behavior |
|------|-------------|
| 400 | Show field validation message |
| 401 | Redirect to login |
| 404 | Show "Not found or already deleted" |
| 422 | Show business rule error (e.g., future date) |

---

## 19. Reports (Submit Complaint)

### POST /api/v1/reports
```json
{
  "targetId": "pharmacy-guid",
  "targetType": "Pharmacy",
  "reason": "Delayed delivery",
  "description": "Order was 3 hours late with no update."
}
```

---

## 20. Ratings

### POST /api/v1/ratings
```json
{
  "targetId": "pharmacist-guid",
  "targetType": "Pharmacist",
  "score": 5,
  "comment": "Very professional and responsive!"
}
```

> `targetType` values: `Pharmacist`, `Pharmacy`
> `score` values: 1 to 5

---

## 21. Patient App — Full Business Flow

### Onboarding Flow
```
1. Patient downloads app → Firebase login/register
2. POST /api/v1/users/sync
   → If isNewUser = true: navigate to onboarding screen
3. POST /api/v1/users/profile/complete
   → Fill name, phone, gender, dateOfBirth, avatarUrl
   → On success: navigate to home screen
4. POST /api/v1/users/me/addresses → add home delivery address
5. POST /api/v1/users/me/devices → register FCM token for push notifications
```

### Medical History Setup Flow
```
--- Add a Disease or Allergy (no file needed) ---
6. POST /api/v1/patients/conditions
   → { type: "ChronicDisease", name: "Type 2 Diabetes", diagnosedAt: "2019-03-15" }
   → Condition card appears on profile

--- Upload a Lab Result ---
7. POST /api/files/upload (multipart) → save returned url
8. POST /api/v1/medical-records
   → { fileUrl: "...", type: "LabResult", title: "CBC", recordDate: "2026-04-01" }
   → Record appears in timeline

--- View History ---
9. GET /api/v1/medical-records → full document timeline
   GET /api/v1/medical-records?type=LabResult → only lab results
   GET /api/v1/patients/conditions → all diseases and allergies
   GET /api/v1/patients/conditions?type=Allergy → only allergies

--- Delete a Record ---
10. DELETE /api/v1/medical-records/{id} → confirm dialog → remove card
    DELETE /api/v1/patients/conditions/{id} → confirm dialog → remove card
```

### Order Flow
```
--- Search & Order ---
11. GET /api/v1/drugs/search?q=Panadol → find drug
12. GET /api/v1/drugs/{id} → check details
    → if requiresPrescription = true:
       POST /api/files/upload → get image URL
       POST /api/v1/prescriptions → submit prescription
13. GET /api/v1/pharmacies/nearby → pick pharmacy
14. POST /api/v1/orders → create order with items
    → orderStatus = Pending
    → Pharmacy receives NEW_ORDER push notification

--- Wait for Response ---
15. Patient receives push: ORDER_RESPONSE
    → data.orderId, data.price
16. GET /api/v1/orders/{id} → see finalPrice and pharmacy notes

--- Decide ---
17a. Confirm: POST /api/v1/orders/{id}/confirm
     → orderStatus = Confirmed
     → Pharmacy receives ORDER_CONFIRMED

17b. Cancel: DELETE /api/v1/orders/{id}/cancel
     → orderStatus = Cancelled
     → Only possible when status is Pending

--- Track ---
18. GET /api/v1/orders/{id} → see statusHistory
19. When fulfilled → orderStatus = Completed
```

### UI State Machine — Orders
| Status | UI State | Patient Actions |
|---|---|---|
| `Pending` | "Waiting for pharmacy..." spinner | Cancel only |
| `PricingResponded` | Show price prominently | Confirm or Cancel |
| `Confirmed` | "Order confirmed. Preparing..." | View only |
| `Completed` | "Delivered ✓" | Rate pharmacy |
| `Rejected` | "Pharmacy rejected order" | Create new order |
| `Cancelled` | "Cancelled" | Create new order |

---

## 22. Error Reference

| Code | Reason |
|------|--------|
| 400 | Bad request — missing or invalid fields |
| 401 | Token missing, expired, or invalid |
| 403 | Wrong role — patient cannot access pharmacist/admin endpoints |
| 404 | Resource not found |
| 409 | Conflict — duplicate resource (e.g., address already default) |
| 422 | Business rule violation (e.g., cancelling a confirmed order) |
| 429 | Rate limited — 100 requests per minute per IP |
| 500 | Unexpected server error |

**Error Response:**
```json
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "errors": ["Items list cannot be empty.", "DeliveryAddressId is required."]
}
```
