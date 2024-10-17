#load("@build_bazel_rules_http//lib:http.bzl", "http")
load("http.star", "http")

def _get_access_token():
    auth_url = "https://www.strava.com/oauth/token"
    auth_payload = {
        "client_id": credentials.client_id,
        "client_secret": credentials.client_secret,
        "refresh_token": credentials.refresh_token,
        "grant_type": "refresh_token",
        "f": "json",
    }
    
    response = http.request(
        "POST",
        auth_url,
        json=auth_payload,
        headers={"Content-Type": "application/json"},
    )
    
    return response.json()["access_token"]

def _get_activities(access_token):
    header = {"Authorization": f"Bearer {access_token}"}
    activities_url = "https://www.strava.com/api/v3/athlete/activities"
    all_act_param = {"per_page": 10, "page": 1}
    
    response = http.request(
        "GET",
        activities_url,
        headers=header,
        query_params=all_act_param,
    )
    
    return response.json()

def _get_activity_details(access_token, activity_id):
    header = {"Authorization": f"Bearer {access_token}"}
    specific_act_url = f"https://www.strava.com/api/v3/activities/{activity_id}"
    last_act_param = {"include_all_efforts": True}
    
    response = http.request(
        "GET",
        specific_act_url,
        headers=header,
        query_params=last_act_param,
    )
    
    return response.json()

def analyze_activity(access_token, activity_id):
    try:
        activities = _get_activities(access_token)
        last_act_id = activities[0]["id"]
        
        if last_act_id != activity_id:
            print("Activity not found")
            return
        
        last_act_details = _get_activity_details(access_token, last_act_id)
        
        act_prs = last_act_details["best_efforts"]
        if act_prs:
            for split in act_prs:
                if split["pr_rank"]:
                    print(f"{split['name']} was the {split['pr_rank']}th fastest time at {split['moving_time']} seconds.")
                else:
                    print(f"No PR recorded for {split['name']}")
        else:
            print("No PRs recorded during this activity")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

# Usage
access_token = _get_access_token()
analyze_activity(access_token, "123456789")  # Replace with actual activity ID
