# Patient App API Documentation

**Base URL:** `http://148.230.114.124:8080`
**Version:** v1 | **Auth:** Firebase JWT (Bearer Token) | **Role:** `Patient`

---

## 1. Overview

This file documents all APIs used by the **Patient Mobile App** (Flutter).

Patients can:
- Register and sync their profile
- Search for drugs in the global catalog
- Browse and find pharmacies
- Create orders for drugs (with or without prescriptions)
- Upload prescriptions
- Track order status in real time
- Confirm pricing sent by pharmacies
- Request a personal pharmacist
- View medication plans and set reminders
- Track health readings and medical records
- Receive push notifications for order updates

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

> If `isNewUser = true`, this is a first-time login — navigate to onboarding.
> Save `id` (internal user ID) — you may need it in other calls.

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

### PUT /api/v1/users/me
Update profile fields.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```
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
**Response 200:** Returns updated `UserProfileResponse` (same as GET /users/me).

### DELETE /api/v1/users/me
Soft-deletes the account. No body required.

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

### POST /api/v1/health-readings
```json
{
  "type": "BloodSugar",
  "value": 110.0,
  "unit": "mg/dL",
  "notes": "Fasting reading"
}
```

> `type` values: `BloodPressure`, `BloodSugar`, `Weight`, `Temperature`, `HeartRate`, `OxygenSaturation`

### GET /api/v1/health-readings
### GET /api/v1/health-readings/history

---

## 18. Medical Records

### POST /api/v1/medical-records
```json
{
  "type": "Diagnosis",
  "title": "Annual Checkup",
  "description": "All results normal",
  "fileUrl": "https://s3.amazonaws.com/pharmacare/report.pdf",
  "recordDate": "2026-04-01"
}
```

### GET /api/v1/medical-records

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

## 21. Patient App — Full Business Flow (Story)

```
1. Patient downloads app → Firebase login
2. POST /api/v1/users/sync → profile created with role: Patient
3. POST /api/v1/users/me/addresses → add home address
4. POST /api/v1/users/me/devices → register FCM token

--- Search & Order ---
5. GET /api/v1/drugs/search?q=Panadol → find drug
6. GET /api/v1/drugs/{id} → check details
   → if requiresPrescription = true:
      POST /api/files/upload → get image URL
      POST /api/v1/prescriptions → submit prescription
7. GET /api/v1/pharmacies/nearby → pick pharmacy
8. POST /api/v1/orders → create order with items
   → orderStatus = Pending
   → Pharmacy receives NEW_ORDER push notification

--- Wait for Response ---
9. Patient receives push: ORDER_RESPONSE
   → data.orderId = "order-guid", data.price = "125.50"
10. GET /api/v1/orders/{id} → see finalPrice and notes

--- Decide ---
11a. Confirm: POST /api/v1/orders/{id}/confirm
     → orderStatus = Confirmed
     → Pharmacy receives ORDER_CONFIRMED

11b. Cancel: DELETE /api/v1/orders/{id}/cancel
     → orderStatus = Cancelled

--- Track ---
12. GET /api/v1/orders/{id} → see statusHistory
13. When complete → orderStatus = Completed
```

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
