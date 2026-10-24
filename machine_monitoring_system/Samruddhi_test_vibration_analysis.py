
# Vibration limits
vibration_limits = {
    101: 4.5,
    102: 5.0,
    103: 3.5
}

# Vibration readings + test cases
readings = [
    # Original readings
    {"machine_id": 101, "timestamp": "09:00", "vibration_mm_s": 4.0},
    {"machine_id": 101, "timestamp": "09:15", "vibration_mm_s": 4.8},
    {"machine_id": 101, "timestamp": "09:30", "vibration_mm_s": 5.9},
    {"machine_id": 102, "timestamp": "09:00", "vibration_mm_s": 5.2},
    {"machine_id": 102, "timestamp": "09:15", "vibration_mm_s": 4.7},
    {"machine_id": 103, "timestamp": "09:00", "vibration_mm_s": 4.1},

    # Additional test cases
    {"machine_id": 101, "timestamp": "10:00", "vibration_mm_s": 4.5},
    {"machine_id": 102, "timestamp": "10:00", "vibration_mm_s": 5.5},
    {"machine_id": 102, "timestamp": "10:15", "vibration_mm_s": 6.0},
    {"machine_id": 103, "timestamp": "10:00", "vibration_mm_s": 4.0},
    {"machine_id": 103, "timestamp": "10:15", "vibration_mm_s": 3.0},
    {"machine_id": 103, "timestamp": "10:30", "vibration_mm_s": 4.2},
    {"machine_id": 999, "timestamp": "10:00", "vibration_mm_s": 5.0},
    {"machine_id": 101, "timestamp": "10:30", "vibration_mm_s": None},
    {"machine_id": 101, "timestamp": "10:45", "vibration_mm_s": "abc"}
]


# Function to classify vibration
def check_vibration(machine_id, vibration, vibration_limits):

    if machine_id not in vibration_limits:
        return "INVALID MACHINE"

    if vibration is None:
        return "MISSING VALUE"

    try:
        vibration = float(vibration)
    except (TypeError, ValueError):
        return "INVALID VALUE"

    limit = vibration_limits[machine_id]

    if vibration <= limit:
        return "NORMAL"
    elif vibration <= limit * 1.25:
        return "WARNING"
    else:
        return "CRITICAL"


# Function to analyze vibration
def analyze_vibration(readings, vibration_limits):

    classified_readings = []
    incidents = []
    machine_readings = {}

    # Group readings by machine
    for reading in readings:
        machine_id = reading["machine_id"]
        machine_readings.setdefault(machine_id, []).append(reading)

    # Analyze each machine
    for machine_id, records in machine_readings.items():

        records.sort(key=lambda x: x["timestamp"])

        consecutive_count = 0
        incident_start = None
        incident_end = None

        for reading in records:

            vibration = reading.get("vibration_mm_s")
            status = check_vibration(
                machine_id, vibration, vibration_limits
            )

            classified_readings.append({
                "machine_id": machine_id,
                "timestamp": reading["timestamp"],
                "vibration_mm_s": vibration,
                "status": status
            })

            if status in ("WARNING", "CRITICAL"):

                if consecutive_count == 0:
                    incident_start = reading["timestamp"]

                consecutive_count += 1
                incident_end = reading["timestamp"]

            else:
                if consecutive_count >= 2:
                    incidents.append({
                        "machine_id": machine_id,
                        "start_time": incident_start,
                        "end_time": incident_end
                    })

                consecutive_count = 0
                incident_start = None
                incident_end = None

        # Check incident at the end of readings
        if consecutive_count >= 2:
            incidents.append({
                "machine_id": machine_id,
                "start_time": incident_start,
                "end_time": incident_end
            })

    return classified_readings, incidents


# Run the function
classified_readings, incidents = analyze_vibration(
    readings, vibration_limits
)

# Print classified readings
print("CLASSIFIED READINGS")

for reading in sorted(
    classified_readings,
    key=lambda x: (x["machine_id"], x["timestamp"])
):
    print(reading)

# Print incident summary
print("\nINCIDENT SUMMARY")

if incidents:
    for incident in incidents:
        print(incident)
else:
    print("No incidents detected.")

