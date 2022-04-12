#/bin/bash

# Script played at the start of the katacoda course.
# It should not be copied in the VM.

echo "Waiting for files to be uploaded on the VM."

# Wait for the Katacoda VM to start
while [ ! -f /assets/00.init_script_runner.sh ]; do 
    sleep 1; 
done;

echo "Files found. executing."

# Execute the script on the runner
/assets/00.init_script_runner.sh
