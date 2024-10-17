#Priority TODOs
#Make it only show when the most recent activity has PRs (check the earthquake app for how to do this)
#Get the credentials via user app input
#Cache the access token as to not call the API every time
#Set a frequency for even calling the API, and cache the PR values
#Generate the webp file

import requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning) #Not required, but to ignore the HTTP warning. Look into making that POST request secure if possible
import pprint #Just for debugging
import credentials

#First get the current access token based on the refresh token. Really should cache the access token and only call this every so often. Split this into a function
auth_url = "https://www.strava.com/oauth/token"
auth_payload = {
    'client_id': credentials.client_id,
    'client_secret': credentials.client_secret,
    'refresh_token': credentials.refresh_token, #Refresh token will not expire per Oct 2024 documentation
    'grant_type': "refresh_token",
    'f': 'json'
}
refresh_post = requests.post(auth_url, data=auth_payload, verify=False)
access_token = refresh_post.json()['access_token']


#Use this header to make any of the required GET requests
header = {'Authorization': 'Bearer ' + access_token}

#First get all activities
all_act_param = {'per_page': 10, 'page': 1} #Limit the activities; can make this just one if only looking at most recent
#TODO: Params for activity type, ie runs only
#TODO: Allow users to input a timeframe for how recent of activities to compare to
activites_url = "https://www.strava.com/api/v3/athlete/activities"
activities = requests.get(activites_url, headers=header, params=all_act_param).json()


last_act_id = activities[0]["id"]
last_act_param = {'include_all_efforts': True}
specific_act_url = "https://www.strava.com/api/v3/activities/" + str(last_act_id)
last_act_details = requests.get(specific_act_url, headers=header, params= last_act_param).json()
try:
    act_prs = last_act_details['best_efforts']
    #pprint.pprint(act_prs)
    for split in act_prs:
        if (split['pr_rank']):
            print(split['name'] + ' was the '+ str(split['pr_rank']) + ' fastest time at '+ str(split['moving_time']) + ' seconds.')
            #TODO: Convert this value in seconds to readable time
except:
    print('There were no PRs recorded during this activity')