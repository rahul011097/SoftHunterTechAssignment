# skyline_project

A new Flutter project.

# Project Name: Soft Hunter Technology Assignment

## Overview

This Flutter application implements a login screen, retrieves user data via API calls, and displays the data with pagination. It also integrates Firebase Cloud Messaging (FCM) to send push notifications.


## Tasks

### Task 1: Create a Login Screen
- **Objective**: Develop a login screen that matches the provided design screenshots.
- **Functionality**: 
  - On clicking the **Login** button, the app sends a POST request to the login API.
  - Displays the API response as a Firebase push notification.

**API Details:**
- **Endpoint**: `https://test.bookinggksm.com/api/auth/login`
- **Parameters**:
  - Email: `viks_123@yopmail.com`
  - Password: `vikram`
  - User_type: `4`
  - 

### Task 2: Display Data with Pagination
- **Objective**: Create a new screen to display data from the API with pagination.
- **Functionality**: 
  - Fetch data from the specified API endpoint.
  - Use pagination to load more data as the user scrolls.

**API Details:**
- **Endpoint**: `https://test.bookinggksm.com/api/scheme/view-scheme/55`
- **Property Status Mapping**:
  - `1`: Available
  - `2`: Booked
  - `3`: Hold
  - `4`: Cancel
  - `5`: Complete

### Task 3: Firebase Push Notification
- **Objective**: Implement Firebase push notifications.
- **Functionality**:
  - Subscribe to a topic using the FCM token after receiving a successful login response.
  - Send a push notification to the subscribed topic.

## Setup

1. Clone the repository:
   ```bash
   git clone <>
   

