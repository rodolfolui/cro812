ibmcloud login --sso
ibmcloud target -o rvasquez@co.ibm.com -s test
ibmcloud cf push cro812 --docker-image localhost/cro812
