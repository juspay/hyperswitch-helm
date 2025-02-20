# Load Test with Locust

This directory contains a Locust script for load testing.

## Prerequisites

Before you run the load test, ensure you have the following installed:


- Python 3.6+ : You need a Python version of 3.6 or higher.
- Locust : The load testing tool that will simulate virtual users to test your system.

## Installation

1. Install Locust: If locust is not installed, you can install it using pip : 
    ```sh
    pip install locust
    ```
    This will install the Locust tool on your system, making it ready to run the load tests.

## Running the Test

1. Navigate to the directory : Go to the directory where your Locust script is stored : 
    ```sh
    cd /Users/hyperswitch-helm/load_test
    ```
    Replace the path with the actual location of your script

2. Provide connector API key: Pass the connector API key as an environment variable:
    ```sh
    export CONNECTOR_API_KEY="your_api_key"
    ```
    Replace "your_api_key" with the connector API key

3. Run the Locust test: To start the load test, run the following command:
    ```sh
    locust -f your_locust_script.py
    ```
    Replace your_locust_script.py with the actual filename of your Locust Script.


3. Start the web interface: After running the command, Locust will start up and provide you with a web interface like http://localhost:8089
Open this URL in your web browser, and you'll be able to configure and monitor your load test from the interface.

## Configuration

In the Locust Web Interface, you can configure various aspects of the test, such as the number of virtual users (clients) and the rate at which they are spawned.

### Command Line Options

Locust allows you to further configure your load test through command-line options. These options give you flexibility to adjust parameters dynamically when running the test. Here's an explanation of the commonly used options: 
- `-u`, `--users`: This option sets the number of virtual users you want to simulate. More users will generate more traffic, which is useful for stress testing your application.
   - Example: ```-u 100``` will simulate 100 users.
- `-r`, `--spawn-rate`: This controls how fast the virtual users are spawned. A higher spawn rate means that users will be added more quickly.
   - Example: ```-r 10``` means 10 users will be added every second.
- `-t`, `--run-time`: This sets a time limit for how long the load test will run.
   - Example: ```-t 1h``` will run the test for 1 hour.

Example:
```sh
locust -f your_locust_script.py --users 100 --spawn-rate 10 --run-time 1h
```

## Stopping the Test

To stop the test: 
1. Click the Stop button in the web interface.
2. Alternatively, you can press ```Ctrl + C``` in the terminal to stop the Locust process.