import requests
import feedparser
import requests
import json
import time
import os

parsedIDs = list()

def main():
    while True:
        NewsFeed = feedparser.parse("http://192.168.100.100/rss.html")

        #print(NewsFeed.entries)
        for entry in NewsFeed.entries:
            #print(entry)
            title = entry['title']
            if "Time" in title or "SLA" in title:
                post_id = entry['id'].split("#")[-1]
                if post_id not in parsedIDs:
                    print(title)
                    r = requests.post("https://hooks.slack.com/services/", data=json.dumps({'text': title}))
                    parsedIDs.append(post_id)
            #print(r.status_code)

        time.sleep(5)




if __name__=="__main__":
    
    try:
        exists = os.path.isfile('events.json')
        if exists:
            with open("events.json", "r") as f:
                parsedIDs = json.load(f)

        main()
    except KeyboardInterrupt as e:
        with open("events.json", "w") as f:
            json.dump(parsedIDs, f)
        print(e)
    except Exception as e:
        with open("events.json", "w") as f:
            json.dump(parsedIDs, f)
        print(e)
