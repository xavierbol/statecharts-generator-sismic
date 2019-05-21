Feature: Stopwatch

    Scenario: initial
        Given update context
        When I do nothing
        Then variable elapsed_time equals 0
        And state active is active
        And state timer is active
        And state stopped is active
        And state display is active
        And state actual time is active

    Scenario: test increase by 1 the variable elapsed_time
        Given update context
        When I do nothing
        Then variable elapsed_time equals 0
        When I send event start
        And I wait 1 second
        Then variable elapsed_time equals 1

    Scenario: reset the Stopwatch
        Given update context
        When I send event start
        And I wait 1 second
        Then variable elapsed_time equals 1
        When I wait 1 second
        Then variable elapsed_time equals 2
        When I send event stop
        Then state stopped is active
        And state actual time is active
        When I send event reset
        Then state stopped is active
        And state actual time is active
        And variable elapsed_time equals 0