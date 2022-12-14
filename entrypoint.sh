#!/bin/bash


echo "$INPUT_KUBECONFIG_FILE" |base64 -d > .kubeconfig
export KUBECONFIG=.kubeconfig
export AWS_ACCESS_KEY_ID="$INPUT_AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$INPUT_AWS_SECRET_KEY"

if [ -n "$INPUT_UNINSTALL" ]; then

	echo helm uninstall --wait --timeout $INPUT_TIMEOUT $INPUT_RELEASE

	helm uninstall --wait --timeout $INPUT_TIMEOUT $INPUT_RELEASE

else 

	if [ -n "$INPUT_CHART_REPO" ]; then
		echo adding repo $INPUT_CHART_REPO_ALIAS $INPUT_CHART_REPO
	    helm repo add $INPUT_CHART_REPO_ALIAS $INPUT_CHART_REPO
	fi

	helm repo update
	helm search repo $INPUT_CHART_REPO_ALIAS

	export VALFILE="$(echo $INPUT_VALUE_FILES | awk -F, '{print $(NF)}')"
	echo Searching for instance specific value file for $VALFILE
	export INSTANCE_VALFILE="$(dirname $VALFILE)/${INPUT_INSTANCE}.$(basename $VALFILE)"
	if [ -f "$INSTANCE_VALFILE" ]; then
		INCLUDE_VALFILE="-f $INSTANCE_VALFILE"
		echo Found $INSTANCE_VALFILE :
		cat $INSTANCE_VALFILE
	fi 

	echo helm upgrade --install --wait --timeout $INPUT_TIMEOUT --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INCLUDE_VALFILE $INPUT_RELEASE $INPUT_CHART

	helm template --debug --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INCLUDE_VALFILE $INPUT_RELEASE $INPUT_CHART


	helm upgrade --install --wait --timeout $INPUT_TIMEOUT --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INCLUDE_VALFILE $INPUT_RELEASE $INPUT_CHART

fi
