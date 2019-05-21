Feature: Dishwascher

    Scenario: Dishwascher starts on Stopped state
        When I do nothing
        Then variable finish equals False
        And state Stopped is active

    Scenario: Dishwascher enters in Active state
        When I do nothing
        Then state Stopped is active
        When I send event on
        Then state Active is entered
        And state Lavage is Active

    Scenario: Dishwascher enters in Rincage state and I open the door
        When I do nothing
        Then state Stopped is active
        When I send event on
        Then state Active is entered
        And state Lavage is active
        When I wait 5 seconds
        Then state Lavage is exited
        And state Rincage is entered
        When I send event porteOuverte
        Then state Rincage is exited
        And state Active is exited
        And state Attente is entered

    Scenario: Dishwascher enters in Rincage state and I open the door, then I close the door and dishwasher continues its process
        When I do nothing
        Then state Stopped is active
        When I send event on
        Then state Active is entered
        And state Lavage is active
        When I wait 5 seconds
        Then state Lavage is exited
        And state Rincage is entered
        When I send event porteOuverte
        Then state Rincage is exited
        And state Active is exited
        And state Attente is entered
        When I send event porteFermee
        Then state Attente is exited
        And state Active is active
        And state Rincage is entered

    Scenario: Dishwascher finish its process
        When I do nothing
        Then state Stopped is active
        When I send event on
        Then state Active is entered
        And state Lavage is active
        When I wait 5 seconds
        Then state Lavage is exited
        And state Rincage is entered
        When I wait 2 seconds
        Then state Rincage is exited
        And state Active is active
        And state Sechage is entered
        When I wait 5 seconds
        Then state Sechage is exited
        And variable finish equals True
        And state Active is exited
        And state Stopped is entered
