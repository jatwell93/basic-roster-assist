# Rostering Application - Fair Work API Integration Specification

## ADDED Requirements

### Requirement: Fair Work API Integration

The system SHALL integrate with the Fair Work Commission's Modern Awards Pay Database (MAPD) API to retrieve and maintain current award rates for accurate wage calculations and compliance.

---

## 1. API Overview

### Modern Awards Pay Database (MAPD) API

**Purpose:** Provides access to over 70,000 modern award minimum rates of pay, allowances, overtime rates, and penalty rates across all 154 Australian modern awards.

**Availability:** RESTful API available at https://www.fwc.gov.au/work-conditions/awards/modern-awards-pay-database

**Key Benefits:**
- Real-time access to updated award rates
- Automated compliance with Fair Work conditions
- Eliminates manual pay rate calculations and data entry errors
- Removes need for recalculating rates after annual wage review changes

---

## 2. API Authentication & Access

**Registration Required:** Businesses and software providers must register with the FWC to obtain an API key.

**Authentication Method:** API key-based authentication (to be confirmed with FWC during registration)

**Supported Formats:**
- REST (recommended for web applications)
- SOAP (for legacy system compatibility)

**Access Restrictions:** Current access is restricted to registered businesses and authorized software providers.

---

## 3. Core Data Available via API

The MAPD API provides access to the following award-related data:

### 3.1 Primary Data Points
- **Minimum Base Pay Rates** - Base hourly and weekly rates by classification
- **Allowances** - Meal allowances, clothing allowances, special rates
- **Penalty Rates** - Weekend rates, public holiday rates, shift penalties
- **Overtime Rates** - Time-and-a-half, double-time provisions
- **Loading Rates** - Casual loading (typically 25%), higher duties loading
- **Classification Structures** - Specific classification definitions per award

### 3.2 Award Information
- Award name and award code
- Effective dates for rate changes
- Classification levels and their requirements
- Industry-specific conditions

### 3.3 Special Considerations
- High income threshold (currently $183,100 annually from 1 July 2025)
- Junior employee rates (under 21 years)
- National Minimum Wage rates (for non-award employees)
- Casual loading percentages

---

## 4. Integration Scenarios

### Scenario 1: Award Rate Retrieval During Staff Setup

**WHEN** an admin configures a new staff member and selects their award classification

**THEN** the system SHALL:
1. Query the MAPD API with the award name and classification
2. Retrieve the current base hourly rate and applicable allowances
3. Store the effective date of the rates
4. Display the retrieved rate to the admin for confirmation
5. Save the rate and effective date to the staff member's record

**Expected Response Time:** <500ms

### Scenario 2: Automated Rate Updates After Annual Wage Review

**WHEN** the Fair Work Commission updates award rates (typically post annual wage review, July)

**THEN** the system SHALL:
1. Query the MAPD API for all configured awards used in the system
2. Compare returned rates against stored rates
3. Flag affected staff members whose rates have changed
4. Generate a report showing:
   - Staff members affected
   - Previous rates vs new rates
   - Effective date of changes
   - Cumulative wage impact
5. Allow admin to approve and apply bulk updates

**Update Frequency:** Automated daily check for changes (recommended)

### Scenario 3: Multi-Classification & Allowance Calculation

**WHEN** a roster is generated for an employee with mixed classifications or applicable allowances

**THEN** the system SHALL:
1. Retrieve classification-specific rates from the MAPD API
2. Calculate applicable allowances based on shift type
3. Apply penalty rates if applicable (weekends, public holidays)
4. Apply casual loading if employee is casual classification
5. Display wage calculation breakdown in the roster

### Scenario 4: Compliance Verification

**WHEN** a payroll export is generated or approved

**THEN** the system SHALL:
1. Query the MAPD API to verify current rates for each award
2. Cross-check employee wage calculations against current rates
3. Flag any rates that are below current award minimums
4. Generate a compliance report for audit purposes

### Scenario 5: API Failure & Fallback

**WHEN** the MAPD API is unavailable or returns an error

**THEN** the system SHALL:
1. Log the API error with timestamp and error code
2. Use the most recently cached award rates
3. Display a warning banner indicating rates may be outdated
4. Allow manual entry/override of wage rates (with audit logging)
5. Prevent roster or payroll processing until rates are confirmed
6. Notify admin of the API failure
7. Retry the API connection at regular intervals (recommended: every 15 minutes)

**Fallback Behavior:**
- Cache expiry: 7 days maximum (recommend daily updates)
- Manual entry requires admin approval and documented reason
- Maintain audit trail of all manual overrides

---

## 5. API Request/Response Model

### 5.1 Request Structure (Typical)

```json
{
  "awardCode": "MA000001",
  "classification": "Level 2",
  "effectiveDate": "2025-07-01",
  "employmentType": "full-time | part-time | casual"
}
```

### 5.2 Response Structure (Typical)

```json
{
  "awardName": "Award Title",
  "awardCode": "MA000001",
  "classification": "Level 2",
  "effectiveDate": "2025-07-01",
  "rates": {
    "baseHourly": 25.50,
    "baseWeekly": 969.00,
    "casualLoading": 0.25,
    "loadedHourly": 31.88
  },
  "allowances": [
    {
      "name": "Meal Allowance",
      "amount": 15.00,
      "frequency": "per day"
    }
  ],
  "penaltyRates": {
    "weekend": 1.5,
    "publicHoliday": 2.5,
    "overnight": 1.2
  },
  "lastUpdated": "2025-07-01T00:00:00Z",
  "nextReviewDate": "2026-06-30"
}
```

---

## 6. Technical Implementation Requirements

### 6.1 API Integration Layer

- **Endpoint Management:** Centralized configuration for MAPD API endpoint URL
- **Authentication:** Secure storage of API key (environment variables or secure vault)
- **Rate Limiting:** Implement exponential backoff for API calls to respect rate limits
- **Connection Timeout:** 30 seconds maximum
- **Retry Logic:** Up to 3 retries with exponential backoff (1s, 2s, 4s)

### 6.2 Caching Strategy

- **Cache Duration:** 24 hours (daily refresh)
- **Cache Invalidation:** Manual refresh option + automatic on new employee award setup
- **Storage:** Database table: `award_rates_cache` with fields:
  - award_code
  - classification
  - base_rate
  - effective_date
  - cached_at
  - expires_at

### 6.3 Error Handling

| Error Code | Condition | Action |
|-----------|-----------|--------|
| 200 | Success | Process response normally |
| 400 | Bad Request | Log error, retry with corrected parameters |
| 401 | Unauthorized | Check API key validity, alert admin |
| 403 | Forbidden | API key inactive, alert admin |
| 404 | Not Found | Award code invalid, notify admin to verify |
| 429 | Rate Limited | Implement exponential backoff, retry later |
| 500+ | Server Error | Use cached rates, retry in 5 minutes |

### 6.4 Data Validation

- Validate API response schema before processing
- Verify effective dates are in valid format (ISO 8601)
- Confirm rate values are positive numbers with max 2 decimal places
- Cross-check award codes against known FWC award registry

---

## 7. Audit & Compliance Logging

### 7.1 Audit Requirements

The system SHALL maintain an immutable audit log of all:
- API calls made (timestamp, award code, classification, response)
- Rate updates applied to staff records
- Manual rate overrides (user, reason, old rate, new rate)
- Compliance verification checks performed
- API failures and cache usage events

### 7.2 Reporting

Generate compliance reports showing:
- Staff members paid below current award minimums (if any)
- Last MAPD API update check timestamp
- List of staff on cached vs live rates
- Manual override audit trail

---

## 8. User Interface Requirements

### 8.1 Admin Dashboard Elements

- **API Status Indicator:** Shows current connection status to MAPD API
- **Rate Update Button:** Manual trigger for immediate rate refresh
- **Staff Award Management:** Display current award rates with "Last Updated" timestamp
- **Compliance Alerts:** Visual warnings for potential compliance issues

### 8.2 Fallback UI

- Warning banner when using cached rates
- Manual rate entry form with required justification field
- Override confirmation dialog requiring explicit approval

---

## 9. Testing & Validation Strategy

### 9.1 Unit Tests

- Verify API request payload construction
- Test response parsing and error handling
- Validate rate caching logic
- Test fallback behavior during API failures

### 9.2 Integration Tests

- End-to-end flow: Award selection → API call → Rate storage → Roster calculation
- Test with various award codes and classifications
- Simulate API timeouts and error responses
- Verify cache expiration and refresh logic

### 9.3 Compliance Testing

- Verify calculated wages meet or exceed current award minimums
- Cross-check rates against FWC official rates
- Test for any missed allowances or penalty rates

---

## 10. Future Enhancements

- Real-time API notifications when FWC publishes rate changes
- Support for enterprise agreements and custom rates (out of scope for MVP)
- Webhook integration for automated compliance notifications
- Predictive wage impact analysis based on historical rate trends

---

## 11. References

- **FWC MAPD API:** https://www.fwc.gov.au/work-conditions/awards/modern-awards-pay-database
- **FWC Integration Guide:** Modern Awards Pay Database API Integration Best Practices Guide (provided)
- **Fair Work Legislation:** Fair Work Act 2009 (Cth)
- **Current Award Information:** https://www.fairwork.gov.au/employment-conditions/awards

---

## Appendix A: Known Award Codes

To be populated during implementation with frequently-used awards in the target industry. Examples:
- MA000100 - Retail Award 2020
- MA000005 - Hospitality Industry (General) Award 2020
- MA000015 - Restaurant Industry Award 2020
