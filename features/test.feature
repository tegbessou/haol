Feature:
    In order to prove that the Behat Symfony extension is correctly installed
    As a user
    I want to have a demo scenario

    @read-only
    Scenario: List ten users
        When I go to "/"
        Then the response status code should be 200
        And the response should contain "Pedro1"
        And the response should not contain "PedroManual"

    Scenario: Create an user
        When I go to "/create"
        Then the response status code should be 200
        And the response should contain "New user: PedroManual"