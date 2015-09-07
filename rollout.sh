#!/bin/bash

# $Revision: 2487 $ $Date:: 2015-09-07 #$ $Author: serge $

USER=$1
HOST=$2
PACKAGE=$3

CONFIG=./rollout.cfg

show_help()
{
    echo "Usage: rollout.sh USER HOST PACKAGE"
}

if [ -z "$USER" ]
then
    show_help
    exit
fi

if [ -z "$HOST" ]
then
    show_help
    exit
fi

if [ -z "$PACKAGE" ]
then
    show_help
    exit
fi

USERHOST=$USER@$HOST

DATUM=$(date -u +%Y%m%d_%H%M)
NAME=${PACKAGE}_$DATUM
ARCNAME=$NAME.tar.gz

echo "name          = $NAME"
echo "host          = $HOST"
echo "package       = $PACKAGE"
echo "userhost      = $USERHOST"
#exit

if [ ! -f $CONFIG ]
then
    echo "ERROR: config file $CONFIG not found"
    exit
fi

source $CONFIG

if [ -z "$PACKAGE_FILES" ]
then
    echo "ERROR: \$PACKAGE_FILES is not defined"
    exit
fi

echo
echo "package files = $PACKAGE_FILES"
echo "post actions  = $PACKAGE_POST_ACTIONS"
echo

tar cfvz $ARCNAME $PACKAGE_FILES

scp $ARCNAME $USERHOST:
error=$?

#echo error=$error

if [ $error -ne "0" ]
then
    echo "ERROR: scp failed, error code $error"
    exit
fi

#exit

ssh $USERHOST "\
mkdir $NAME; \
tar xfvz $ARCNAME -C $NAME; \
ln -sf ~/$NAME ~/$PACKAGE; \
$PACKAGE_POST_ACTIONS; \
"
