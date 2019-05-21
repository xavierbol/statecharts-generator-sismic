Feature: CruiseControl

    Scenario: Initialisation
        When I do nothing
        Then state CC_Off is active
        And state Off is active
        And variable speed equals 0
        And variable memSpeed equals 0

    Scenario: Car accelerate and we can activate the cruise control
        When I send event turnKey
        Then state On is active
        And state Driving is active
        And state CC_Off is active
        When I send event accelerate
        Then state On is active
        And state Accelerating is active
        When I repeat "I wait 0.11 second" 40 times
        And I send event accelerate
        Then variable speed equals 40
        And state Driving is active
        When I send event on_off
        Then state CC_On is active

    Scenario: CruiseControl modify the speed of car
        Given I reproduce "Car accelerate and we can activate the cruise control"
        When I send event set
        Then state Active is active
        When I send event set
        Then state SetSpeed is exited
        Then state Active is active
        And variable memSpeed equals 41
        And variable speed equals 41

    Scenario: CruiseControl memorize speed to 41 and we accerate to 50 then we activate the cruise control
        Given I reproduce "CruiseControl modify the speed of car"
        When I send event accelerate
        Then state Active is exited
        And state Idle is entered
        And state Driving is exited
        And state Accelerating is entered
        When I repeat "I wait 0.11 second" 10 times
        Then variable speed equals 51
        When I send event accelerate
        Then state Driving is active
        When I send event resume
        Then state Idle is not active
        And state SetSpeed is exited
        And state Active is entered
        And variable speed equals 41
        And variable memSpeed equals 41
