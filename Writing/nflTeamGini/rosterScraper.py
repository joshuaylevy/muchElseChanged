import pandas as pd
import requests
from bs4 import BeautifulSoup
from functools import partial

positionRoot = "https://overthecap.com/contract-history/"
positionStemVect = ["quarterback","running-back", "fullback","wide-receiver","tight-end","left-tackle","left-guard","center","right-guard","right-tackle","interior-defensive-line","edge-rusher","linebacker","safety","cornerback","kicker","punter","long-snapper"]

for stem in positionStemVect:
    # Create unique URL for each position page
    url = positionRoot + stem
    
    # load page html
    page = requests.get(url)
    # Parse html to be readable - This script uses the html.parser parser which is slower than lxml's parser but does not require additional dependencies or installs
    soup = BeautifulSoup(page.content, 'html.parser')
    # The "table" has the "position-table" CSS class
    table = soup.find(class_='position-table')

    #initialize vectors for each variable of interest
    player_names = []
    player_page_links = []
    player_position = []
    
    tableBody = table.find('tbody')
    tableRows = tableBody.find_all('tr')

    for row in tableRows:
        playerObject = row.find('td')
        playerLinkStem = playerObject.find('a').get('href')
        playerFullURL = "https://overthecap.com" + playerLinkStem
        playerName = playerObject.string
        
        player_names.append(playerName)
        player_page_links.append(playerFullURL)
        player_position.append(stem)

    playerPagedf = pd.DataFrame({
        'player' : player_names,
        'link' : player_page_links,
        'position' : player_position
    })

    print("completed:" + stem)



