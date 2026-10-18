# Implementation Plan - Multi-Branch & Course Update

Update Rehnuma AI Institute to support multiple branches (prioritizing Charbagh) and new course offerings with complex fee structures.

## User Review Required

> [!IMPORTANT]
> - **Data Migration**: Existing students/admissions will be associated with the 'manglor' branch by default.
> - **Matric Science Fees**: The system will handle multi-subject selections for Matric Science with a dynamic fee calculation.

## Proposed Changes

### Data Models

#### [NEW] [branch_model.dart](file:///D:/rehnuma_ai/lib/models/branch_model.dart)
- Define `BranchModel` with fields: `id`, `name`, `location`, `isActive`, `isMainBranch`, `phone`.

#### [NEW] [batch_model.dart](file:///D:/rehnuma_ai/lib/models/batch_model.dart)
- Define `BatchModel` with fields: `id`, `name`, `branchId`, `courseId`, `startDate`, `duration`, `status`, `teacher`.

#### [admission_model.dart](file:///D:/rehnuma_ai/lib/models/admission_model.dart)
- Add `branchId`, `parentPhone`, `selectedSubjects` (List<String>), `monthlyFee`.

#### [student_model.dart](file:///D:/rehnuma_ai/lib/models/student_model.dart)
- Add `branchId`, `parentPhone`, `selectedSubjects`.

---

### Services

#### [NEW] [branch_service.dart](file:///D:/rehnuma_ai/lib/services/branch_service.dart)
- CRUD operations for the `branches` collection.

#### [firestore_service.dart](file:///D:/rehnuma_ai/lib/services/firestore_service.dart)
- Update `submitAdmission` to include new fields.
- Add `getBranches`, `getBatches` (if not in separate services).

---

### Admin Features

#### [admin_shell.dart](file:///D:/rehnuma_ai/lib/admin/dashboard/admin_shell.dart)
- Add 'Branches' and 'Batches' to sidebar navigation.

#### [NEW] [admin_branches_page.dart](file:///D:/rehnuma_ai/lib/admin/branches/admin_branches_page.dart)
- Manage branch status (Active/Paused).

#### [admin_overview_page.dart](file:///D:/rehnuma_ai/lib/admin/dashboard/admin_overview_page.dart)
- Add branch filtering to stats.

---

### Public Website

#### [app_constants.dart](file:///D:/rehnuma_ai/lib/core/constants/app_constants.dart)
- Update primary location to Charbagh.
- Add "Classes Starting 1 September 2026" text.

#### [admissions_page.dart](file:///D:/rehnuma_ai/lib/features/admissions/admissions_page.dart)
- Add Branch selection (default: Charbagh).
- Add Parent/Guardian phone field.
- Add Subject selection for 'Matric Science Coaching'.

---

## Verification Plan

### Automated Tests
- N/A (Project follows manual verification for UI/DB changes).

### Manual Verification
1. **Admissions**: Submit an admission for Charbagh and verify it appears in Admin with correct branch.
2. **Branch Management**: Pause 'Manglor' and check that it's no longer selectable in new admissions.
3. **Fees**: Select 'Matric Science' with 3 subjects and verify fee is calculated as Rs. 2,000.
4. **Dashboard**: Filter dashboard by 'Charbagh' and verify student counts.
