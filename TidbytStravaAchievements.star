load("http.star", "http")
load("render.star", "render")
load("encoding/json.star", "json")

def _get_access_token():
    auth_url = "https://www.strava.com/oauth/token"
    auth_payload = {
        #"client_id": credentials.client_id,
        #"client_secret": credentials.client_secret,
        #"refresh_token": credentials.refresh_token,
        "client_id": '137155',
        "client_secret": 'ab1c3cc9db749dc4a573b77e119f1dba76441c36',
        "refresh_token": '828435407c1f9b36bcf573c347244b781db7b49e',
        "grant_type": "refresh_token",
        "f": "json",
    }
    
    response = http.post(
        auth_url,
        params=auth_payload,
        headers={"Content-Type": "application/json"},
    )
    
    return response.json()["access_token"]


def _get_activities(access_token):
    header = {"Authorization": "Bearer " + access_token}
    activities_url = "https://www.strava.com/api/v3/athlete/activities"
    all_act_param = {"per_page": '10', "page": '1'}
    
    response = http.get(
        activities_url,
        headers=header,
        params=all_act_param,
    )

    return response.json()


def _get_activity_details(access_token, activity_id):
    #print(activity_id)
    specific_act_url = "https://www.strava.com/api/v3/activities/" + activity_id
    header = {"Authorization": "Bearer " + access_token}
    last_act_param = {'include_all_efforts': 'True'}
    
    response = http.get(
        specific_act_url,
        headers=header,
        params=last_act_param,
    )
    
    return response.json()

def analyze_activity(access_token):
    activities = _get_activities(access_token)
    if activities[0]["id"]:
        last_act_id = remove_sci_notation(activities[0]['id'])
        last_act_details = _get_activity_details(access_token, last_act_id)
        act_prs = last_act_details["best_efforts"]
        if act_prs:
            for split in act_prs:
                if split["pr_rank"]:
                    print(split['name'] + " was the " + str(int(split['pr_rank'])) + "th fastest time at "+ str(int(split['moving_time'])) + " seconds.")
                    PRs.append(split['name'] + " was the " + str(int(split['pr_rank'])) + "th fastest time at "+ str(int(split['moving_time'])) + " seconds.")
                else:
                    print("No PR recorded for " + split['name'])
                    PRs.append("No PR recorded for " + split['name'])
        else:
            print("No PRs recorded during this activity")
            PRs.append("No PRs recorded during this activity")


def remove_sci_notation(num):
    #Large numbers are only being returned in scientific notation, and Starlark does not have a built in way to convert
    #revisit this, Im sure its overcomplicated
    parts = str(num).split('e')
    whole_part = parts[0]
    exp = int(parts[1]) if len(parts) > 1 else 0
    formatted_num = whole_part.rstrip('0').replace('.', '').rstrip('.')
    zeros_to_add = max(0, -exp)
    formatted_num += '.' * zeros_to_add
    return formatted_num


def render_on_screen(PRs):
    return render.Root(
        #child = render.Text(str(PRs))
        child = render.Text("Hello, World!")
    )

def main(PRs): #Need to organize the functions better, so keeping this empty for now
    print('Starting up')
    return render.Root(
        child = render.WrappedText(
            content=str(PRs),
            width=50,
        )
        #child = render.Text("Hello, World!")
    )


PRs = []
access_token = _get_access_token()
analyze_activity(access_token)
print(PRs)
render_on_screen(PRs)
main(PRs)