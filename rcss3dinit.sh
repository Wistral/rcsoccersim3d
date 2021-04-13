DIR=$(cd $(dirname $0); pwd)
echo "$0 in $DIR"

SHLRC=".$(basename ${SHELL})rc"
echo  "add rc commands to ${SHLRC}"

cat <<EOF
export PATH=$DIR/bin:\$PATH
export LD_LIBRARY_PATH=$DIR/lib:$DIR/lib/rcssserver3d:$DIR/lib/simspark:\$LD_LIBRARY_PATH
EOF

cat >> ~/${SHLRC} <<EOF
export PATH=$DIR/bin:\$PATH
export LD_LIBRARY_PATH=$DIR/lib:$DIR/lib/rcssserver3d:$DIR/lib/simspark:\$LD_LIBRARY_PATH
EOF