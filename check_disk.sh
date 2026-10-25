#!/bin/bash
SEUIL=${1:-80}
UTILISATION=$(df / | tail -1 | awk '{print $5}' | tr -d "%")
if [ "$UTILISATION" -ge "$SEUIL" ]; then
echo "Disque presque plein : ${UTILISATION} % "
exit 1
else
echo "Disque OK : ${UTILISATION} % "
exit 0
fi
