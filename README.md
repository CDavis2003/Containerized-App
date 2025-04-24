This is to be deployed on a Ubuntu 22.04 server, although it should work on anything that can run docker and bashscripts

Clone the github. Open the "HACWAfinal" directory and then open the "HACWA" directory. Now you may run docker commands. 

All you should have to do is simply run the "swarm-autoscale.sh" script. Allow it time to deploy. 
You can then connect through port 80 using the IP address of your device.

If for any reason it doesn't want to start or is acting strange. It may be neccessary to alter the Threshold values inside 
of the swarm-autoscale.sh script. They are set abnormally low to help with testing. You may need to raise them if it keeps 
attempting to create more containers and wont connect.

When you are done you will need to run the following commands to ensure that your system resources are freed and that
the script will work the next time.

sudo docker swarm leave --force
sudo docker rmi webapp:1.0

these stop the swarm and destroy the images build.
The script builds the web sesrvice from a build file at deployment.
